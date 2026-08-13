# Good and Bad Tests

## Good

Integration-style, through real interfaces:

```typescript
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Public API only, describes WHAT not HOW, one logical assertion, survives internal refactors.

## Bad

```typescript
// Implementation-coupled: asserts on internal calls
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});

// Side channel: bypasses the interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});
// Instead: retrieve through the interface (getUser) and assert on that.

// Tautological: expected value recomputed the way the code computes it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});
// Instead: expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
```

## Mocking

Mock at **system boundaries** only: external APIs, time/randomness, sometimes the filesystem or database (prefer a test DB). Never your own modules or internal collaborators.

Design boundaries for mockability:

- **Dependency injection** — pass external clients in rather than constructing them internally.
- **SDK-style interfaces** — one specific function per external operation (`api.getUser(id)`, `api.createOrder(data)`) instead of a generic fetcher; each mock then returns one shape, with no conditional logic in test setup.
