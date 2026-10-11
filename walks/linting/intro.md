# Linting smallwikiapp, one move at a time

This walk takes the moves about format and lint out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the command and
its tests work, and no tool checks the code.

The moves add ruff, which formats the code and then finds problems in it. The next moves fix each problem. Then a
recipe checks the configuration, and another runs every check, and a git hook runs them before each commit.
Later, the linter asks for a type on every parameter and return, and the moves after it add the types. The last
move checks the configuration of the second package.

Each piece starts from the code before its first move, so each one starts with `just setup`.
