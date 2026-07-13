---
name: seo-geo-audit
description: Audit a single web page's SEO and GEO (Generative Engine Optimization) — cross-checking the live page against its source in the repo — and produce a graded scorecard with impact-ranked, source-pointed fixes. Use when the user wants to audit, grade, or improve a page's SEO or GEO, mentions robots.txt / sitemap.xml / llms.txt / meta tags / alt text / structured data / keywords, or asks whether a page is optimized for search engines or AI answer engines.
---

Audit one page along two axes — **SEO** (how search engines crawl, index, and rank it) and **GEO** (how AI answer engines discover, parse, and cite it) — then grade it and hand back the highest-**leverage** fixes.

Perfection is not the bar. Every real page has warts; the job is an honest snapshot plus the fixes that move the needle most for the effort. Rank by leverage, don't chase a perfect score.

The audit cross-checks two views of the page: the **live** output (what crawlers actually receive) and the **source** in the repo (what to edit). A finding is only actionable once it names the file.

## Process

### 1. Pin the target

Get the **live URL**. Then locate its **source** in the repo — the route/template/component that renders it, plus origin-level static files: `robots.txt`, `sitemap.xml`, `llms.txt`. If the URL maps to no source here, audit live-only and say so up front.

### 2. Gather

- Fetch the live page (`WebFetch`): rendered HTML, response headers, final status, redirect chain.
- Fetch `<origin>/robots.txt`, `<origin>/sitemap.xml`, `<origin>/llms.txt`.
- Read the matching **source** files for the page and those three static files.
- If the fetched HTML is thin (a JS-rendered shell), flag it: a raw fetch may miss client-rendered content, so verdicts on body content are provisional — note this rather than scoring blind.

### 3. Audit

Walk **every** item in the checklist below. No item left unexamined — an item you skip is a gap you're hiding. For each, record:

- **Observed** — the actual state, live and (where relevant) in source.
- **Verdict** — pass / warn / fail / n-a.
- **Fix** — if not pass, what to change and **which source file** to change it in.

### 4. Score

Grade each **category** A–F from its verdicts (weight the heavier items — a missing `<title>` outranks a missing image filename), then give one overall grade. The grade is a snapshot, not a pass/fail gate; a B with three critical fixes pending is more honest than rounding up.

### 5. Report (terminal)

Print, in this order:

1. **Scorecard** — a table of category → grade → one-line reason, plus the overall grade.
2. **Recommendations** — ranked by leverage into tiers: **Critical → High → Medium → Low**. Each line: the fix, the source file to edit, and one clause on why it matters. Critical first; stop expanding a tier when the remaining items are cosmetic.

Close with the single highest-leverage move if the user does only one thing.

---

## Checklist

### Crawlability & indexing
- **HTTP** — 200 status, HTTPS, no needless redirect chain to the canonical URL.
- **robots.txt** — present, valid, not accidentally blocking this page; references the sitemap.
- **sitemap.xml** — present, valid XML, this URL listed, entries resolve 200, `lastmod` present.
- **canonical** — `<link rel="canonical">` present and pointing at the right URL (self, unless intentionally consolidating).
- **meta robots / X-Robots-Tag** — no unintended `noindex` / `nofollow`.
- **hreflang** — correct if multilingual; n-a otherwise.

### On-page SEO
- **title** — present, unique, ~50–60 chars, primary keyword forward.
- **meta description** — present, ~150–160 chars, compelling and accurate.
- **h1** — exactly one, descriptive; heading hierarchy logical with no skipped levels.
- **keywords** — target terms present naturally in title, h1, first paragraph, and URL slug; not stuffed.
- **URL slug** — short, readable, hyphenated.
- **internal links** — present with descriptive anchor text (not "click here").
- **image alt** — every content image has meaningful alt; decorative images have empty `alt=""`.

### Social / sharing
- **Open Graph** — `og:title`, `og:description`, `og:image`, `og:url`, `og:type`.
- **Twitter card** — `twitter:card`, title, description, image.
- **og:image** — resolves and is appropriately sized (~1200×630).

### Structured data (the SEO ↔ GEO bridge)
- **JSON-LD** — schema.org markup present, valid, and matching the page type (Article, Product, Organization, FAQPage, BreadcrumbList…).
- **required props** — the chosen type's required properties are all filled.

### GEO — Generative Engine Optimization
- **llms.txt** — present at origin (and `llms-full.txt` if applicable), pointing AI crawlers at the canonical content.
- **AI-crawler stance** — how robots.txt treats `GPTBot`, `ClaudeBot` / `Claude-User`, `PerplexityBot`, `Google-Extended`. Surface the current stance as a **decision** for the user; don't auto-recommend allow or block.
- **answer-first content** — the page answers its core question directly and early; definitional, self-contained sentences a model can lift verbatim.
- **quotable & factual** — concrete claims, numbers, and named entities with attribution — not fluff. This is what gets cited.
- **entity clarity** — who/what the page is about is stated explicitly and named consistently.
- **Q&A blocks** — FAQ / question-headed sections (backed by FAQPage schema) — highly citable.
- **freshness** — visible and marked publish + updated dates.
- **attribution (E-E-A-T)** — named author and/or organization.
- **semantic HTML** — `article` / `section` / real headings, so the structure parses cleanly.

### Technical health (light touch)
- **viewport** — `<meta name="viewport">` present.
- **lang** — `lang` attribute on `<html>`.
- **weight** — flag only egregious page bloat; deep performance profiling is out of scope — point the user at Lighthouse instead.
