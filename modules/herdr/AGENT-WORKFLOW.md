# Advisor / worker / reviewer in herdr (proposal, not built)

## Layout
One herdr workspace per task, one tab per role group:

```
workspace: <task>
 tab 1 "plan"    advisor (claude, read-only: plans, splits the task, never edits)
 tab 2 "work"    worker-1 | worker-2 | worker-N   each in its own `herdr worktree`
 tab 3 "review"  reviewer (fresh claude context, reviews `git diff <base>...<worker-branch>`)
```

- Workers: `prefix+shift+g` (new_worktree) creates checkouts under `~/.herdr/worktrees/<repo>/<branch-slug>`, so parallel workers never share a working tree.
- Agent names (`[a-z][a-z0-9_-]{0,31}`) make them addressable: `advisor`, `worker-1`, `reviewer`.

## Coordination
Driven through the `herdr agent` / `herdr pane` CLI; the advisor reads the upstream skill (`herdr --skill`), which only activates with `HERDR_ENV=1`:
1. Advisor writes one task file per worker (scope, acceptance checks).
2. `herdr agent start` in each worker pane, then send the task; wait for `idle`/`done` (or `blocked`, which needs Ste).
3. When a worker is `done`, the reviewer gets the branch name and reviews the diff against the base. Findings go back to the worker as a pane message; Ste decides on merge.

## Evaluated
- **Upstream SKILL.md**: right tool for step 2 and 3 (spawn, send, wait). Gives lifecycle states; no orchestration logic, so the advisor prompt carries that.
- **herdr-triage**: read-only dashboard that ranks agents by who needs attention (blocked > done > working > idle). Useful when several workers run; it cannot route work between panes, so it is not the coordination layer. Install later, optional.

## Open questions for Ste
- Should the advisor be allowed to spawn workers itself, or does Ste start them?
- Hand-off format between worker and reviewer: branch name only, or a summary file too?
- Reviewer model/effort (fresh context is the point; same model or a different one?).
