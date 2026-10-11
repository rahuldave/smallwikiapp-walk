# Documenting smallwikiapp, one move at a time

This walk takes the moves about documentation out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the code is
tested, linted and typed, and has almost no documentation.

The moves add smalldocs, which makes the reference from the code and says what has no documentation. Next, the
library, the command and the tests get their docstrings and docments. Then smalldocs builds a site, and the
check of the documentation joins `just check`. The last two moves document the library after it becomes a
package of its own.

Each piece starts from the code before its first move, so each one starts with `just setup`.
