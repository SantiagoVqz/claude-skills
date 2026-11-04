# Simulator

Read this file when the app is a native iOS app, so a repo with a `.xcodeproj` or a `.xcworkspace` and no web screen. It replaces the server and browser parts of step 2. The rest of `ui-check` stays the same.

## Start

Use the build command and the simulator in the `## iOS tests` section of `AGENTS.md`, then run these one at a time:

- `xcrun simctl boot <udid>`. A simulator that is already booted answers with an error: go on.
- `xcrun simctl install <udid> DerivedData/Build/Products/Debug-iphonesimulator/<app>.app`
- `xcrun simctl launch <udid> <bundle id>`

## Steps

`simctl` cannot tap. Reach each state in one of these ways, in this order:

1. A launch argument or a deep link that the app already supports: `xcrun simctl launch <udid> <bundle id> <args>` or `xcrun simctl openurl <udid> <url>`.
2. A UI test in the repo's UI test target that drives the step: run it with `-only-testing`. Leave no new test in the diff.
3. No way to reach it: mark the step ✗ with "not reached", and put it under "Check yourself".

After each step, run `xcrun simctl io <udid> screenshot <scratchpad path>`, and read the image with the Read tool. Compare it with what the step expects.

Sound, haptics and behavior on a real device stay under "Check yourself".

## Close

When a caller or the user is done with the walk, run `xcrun simctl shutdown <udid>`, because a booted simulator keeps its CPU and memory.

Completion: each step has a screenshot that you read, or is marked "not reached".
