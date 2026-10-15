We build `wikiapp`, a small command that prints the title and the summary of a random Wikipedia page. Around the
command we build the project. A tool called uv installs the project's packages, which are code that other people wrote and
that the project uses. The project also gets tests, a library, a formatter for the layout of the code, and a linter
for likely mistakes. It gets a check that each value in the code is the kind of value that the code expects. It also gets checks on
GitHub, documentation made from the code, and a build.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch is a list of
lines to add to a file and lines to take out of it. A command, such as `uv add`, changes its files by itself,
with no patch. In **Build it yourself**, you make each move by hand, and then a command compares your files with the project's. In **Read the
tutorial**, each move is already made, and the text explains what changed.

Each move first says what problem it solves. Then it gives the change, piece by piece, and a command that checks
the result. Each larger part of the tutorial starts with the command `just setup`. The tool `just` runs
short commands that the project names. `just setup` asks uv to install the packages that the code needs at that
point.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi, another tool that installs a project's packages. Where the text says "the original wikiapp", it means that project.

Five shorter tutorials take parts of this one. Each has its own site, for
[testing](https://rahuldave.com/smallwikiapp-walk/testing/),
[linting](https://rahuldave.com/smallwikiapp-walk/linting/),
[docs](https://rahuldave.com/smallwikiapp-walk/docs/),
[just](https://rahuldave.com/smallwikiapp-walk/just/) and
[uv](https://rahuldave.com/smallwikiapp-walk/uv/).
