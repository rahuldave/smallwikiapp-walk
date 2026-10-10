# smallwikiapp-walk

This repository is a timewalk tutorial through the project smallwikiapp. `toc.toml` names two walks over the
same notes. In the walk `do`, the learner makes each move. In the walk `show`, timewalk checks out each move.
The notes are in `walks/tutorial/notes.md`, with a `## step-NN` section for each step and a `### step-NN.k`
section for each move, in commit order.

- `just present do` or `just present` opens the tutorial. `just check` checks the notes against the project.
- `repo/` is the learner's clone of smallwikiapp. `worktree/` is the replay copy of timewalk, a clone of
  `repo/` on the branch `timewalk/replay`. Git tracks neither. timewalk never writes to `repo/`.
- A move keeps the learner's edits and commits in `worktree/`, on a branch `timewalk/saved/<place>`, and does
  not ask. The moves of a step go in order. To go back, use **Restart step**, and then run `just setup`.
- The class material of the teacher makes these files. Do not change the justfile, `toc.toml` or `.gitignore`
  for the needs of one learner. A learner can edit the notes and commit them to a fork.
