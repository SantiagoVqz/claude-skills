# Xcode repos

Read this file when the repo has a `.xcodeproj` or a `.xcworkspace`. Each session found the safe test flags by trial, and one UI test hung for 49 minutes. So the repo keeps one test command, and every subagent reads it from `AGENTS.md`.

## Check the toolchain

- Run `xcodebuild -checkFirstLaunchStatus`. When it fails, give the user `! sudo xcodebuild -license accept`, then `! xcodebuild -runFirstLaunch`.
- Run `xcrun simctl list runtimes`. When no runtime can run the app, tell the user to install one in Xcode.

## Ignore build state

Add `xcuserdata/` and `DerivedData/` to `.gitignore`.

## Write the test commands

Pick the scheme and one simulator by its UDID from `xcrun simctl list devices available`. Add this section to `AGENTS.md`, filled in, outside the `## Agent skills` block:

````markdown
## iOS tests

Build once: `xcodebuild build-for-testing -scheme <scheme> -destination 'platform=iOS Simulator,id=<udid>' -derivedDataPath DerivedData`

Test one class in a cycle: `xcodebuild test-without-building -scheme <scheme> -destination 'platform=iOS Simulator,id=<udid>' -derivedDataPath DerivedData -only-testing:<target>/<class> -parallel-testing-enabled NO -collect-test-diagnostics never -test-timeouts-enabled YES -maximum-test-execution-time-allowance 300`

Run the full suite: the same command with no `-only-testing`.

`-parallel-testing-enabled NO` stops Xcode from booting a clone simulator on each run. `-collect-test-diagnostics never` stops a hang of up to 10 minutes after a failure. `DerivedData` in the worktree goes away with the worktree. Stop a run that passes 15 minutes, and report the end of its log.
````

Completion: the toolchain check passed or the user has the commands, `.gitignore` has both lines, and `AGENTS.md` has the section with a real scheme and UDID.
