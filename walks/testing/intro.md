# Testing smallwikiapp, one move at a time

This walk takes the moves about tests out of the whole tutorial of smallwikiapp. `wikiapp` is a small command
that prints the title and the summary of a random Wikipedia page. The walk starts when the command works and
has no tests.

The moves add pytest and a first test, a fixture, and a mock in place of Wikipedia. Next come tests of the
request, of a failed request, and the coverage of every run. Then the mock moves to `conftest.py`, so that the
library gets tests of its own. Later moves give the tests their types. The test that asks the real
Wikipedia then runs only when you ask for it, and GitHub runs every test. The last move documents the tests.

Each piece starts from the code before its first move, so each one starts with `just setup`.
