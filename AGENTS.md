# smallwikiapp-walk

This repository is a timewalk tutorial through the project smallwikiapp. `toc.toml` names five walks over the
same notes. The walks `show` and `do` are the whole tutorial, and start in watch mode and in do mode. The small
walks `testing`, `linting` and `docs` each take some steps and moves of the whole tutorial, with `select`. In do
mode, the learner makes each move. In watch mode, timewalk checks out each move.

The notes are in `walks/tutorial/notes.md`, with a `## step-NN` section for each step and a `### step-NN.k`
section for each move, in commit order. `walks/tutorial/TUTORIAL-watch.md` and `TUTORIAL-do.md`, `site/` and
`sites/` are copies that timewalk-tutorial makes from the notes. Do not edit them by hand.

- `just present do` or `just present` opens the tutorial. `just check` checks the notes against the project.
- `repo/` is the learner's clone of smallwikiapp. `worktree/` is the replay copy of timewalk, a clone of
  `repo/` on the branch `timewalk/replay`. Git tracks neither. timewalk never writes to `repo/`.
- A move keeps the learner's edits and commits in `worktree/`, on a branch `timewalk/saved/<place>`, and does
  not ask. The moves of a step go in order. To go back, use **Restart step**, and then run `just setup`.
- The class material of the teacher makes these files. Do not change the justfile, `toc.toml` or `.gitignore`
  for the needs of one learner. A learner can edit the notes and commit them to a fork.
