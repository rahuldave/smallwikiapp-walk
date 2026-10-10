# smallwikiapp-walk

This repository is a timewalk tutorial through the project smallwikiapp. `toc.toml` names two walks over the
same notes: `do` (the learner makes each move) and `show` (each move is checked out). The notes are
`walks/tutorial/notes.md`: a `## step-NN` section per step, a `### step-NN.k` section per move, in commit order.

- `just present do` or `just present` opens it; `just check` checks the notes against the project.
- `repo/` is the learner's clone of smallwikiapp; `worktree/` is timewalk's replay copy, a clone of `repo/` on the
  branch `timewalk/replay`. Neither is tracked. timewalk never writes to `repo/`.
- A move keeps the learner's edits and commits in `worktree/` on a branch `timewalk/saved/<place>`, and does not
  ask. The moves of a step go in order: to go back, use **Restart step**, and then `just setup`.
- These files are made from the teacher's class material. Do not change the justfile, `toc.toml` or
  `.gitignore` for one learner's needs. A learner may edit the notes and commit them to their own fork.
