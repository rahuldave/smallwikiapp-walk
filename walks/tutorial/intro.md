We build `wikiapp`, a small command that prints the title and the summary of a random Wikipedia page. Around the
command we build the project. It gets its packages with uv, tests, a library, a formatter, a linter and types. It
also gets checks on GitHub, documentation made from the code, and a build.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

Each move first says what problem it solves. Then it gives
the change, piece by piece, and a command that checks the result. Every section starts with `just setup`, which
makes the environment of the project match the code.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

Five shorter tutorials take parts of this one. Each has its own site, for
[testing](https://rahuldave.com/smallwikiapp-walk/testing/),
[linting](https://rahuldave.com/smallwikiapp-walk/linting/),
[docs](https://rahuldave.com/smallwikiapp-walk/docs/),
[just](https://rahuldave.com/smallwikiapp-walk/just/) and
[uv](https://rahuldave.com/smallwikiapp-walk/uv/).
