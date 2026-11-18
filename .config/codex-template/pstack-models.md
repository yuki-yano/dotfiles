# pstack model configuration

Per-role model overrides for pstack skills. Each pstack SKILL.md names its defaults in a Models section; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `spawn_agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out. A model may carry a reasoning effort, as in `gpt-6.2-sol @xhigh` (levels: low, medium, high, xhigh, max); the role's subagent then runs at that level, each entry of a panel list on its own. `default effort` sets the level for a value without one; `session` uses the runtime's platform mapping to start from the parent session's effort. On Codex this requires active-turn metadata or an explicit effort choice. `session hook: off` stops the supported runtime's pstack routing hook from injecting the poteto-mode mandate; any other value, or no line, leaves it on.

feature, refactoring: gpt-6.2-sol
bug-fix: gpt-6.2-sol
perf-issue: gpt-6.2-sol
hillclimb: gpt-6.2-sol
judgment and prose: gpt-6.2-sol
strongest judgment: gpt-6.2-astra
how explorer: gpt-6.2-sol
how explainer: gpt-6.2-sol
why investigators: gpt-6.2-sol
why synthesizer: gpt-6.2-sol
reflect tooling: gpt-6.2-sol
reflect judgment, divergent, synthesizer: gpt-6.2-sol
arena runners: gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol
arena cross-judge pool: gpt-6.2-astra, gpt-6.2-sol, gpt-6.1-terra, gpt-6-luna
swarm workers: gpt-6.2-sol
architect runners: gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol
interrogate reviewers: gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol, gpt-6.2-sol
thermos reviewers: gpt-6.2-sol
no-comments reviewer: gpt-6.2-sol

default effort: session
session hook: on
