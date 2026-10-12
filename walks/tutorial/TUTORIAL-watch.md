<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# smallwikiapp, one move at a time

In watch mode, you read each move. The notes explain what it changed, and its commit holds the code. [The same tutorial in do mode](TUTORIAL-do.md).

This tutorial goes through the tagged steps of smallwikiapp, and the small commits between them. Each small
commit is a move, one action. The command at the end of a move shows what the move did. Every step starts from
the code of the step before, so every step starts with `just setup`. To take the tutorial in timewalk, where you
can watch each move or make it yourself, see the [README](https://github.com/rahuldave/smallwikiapp-walk#readme).

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

`just walk-update` in the class material makes this copy from
[the notes that timewalk reads](https://github.com/rahuldave/smallwikiapp-walk/blob/main/walks/tutorial/notes.md),
so do not edit it by hand.

- **Each step** links to the code at that step.
- **Each move** links to its commit, which shows what the move changed.
- **A command to run** is in a grey block marked `bash`, and the text under it says what the command prints.
- **Under "Files to read"**, each file links to the file as the move leaves it, and to its change in the commit.

Three small walks take parts of this tutorial. Each has its own site, for
[testing](https://rahuldave.com/smallwikiapp-walk/testing/),
[linting](https://rahuldave.com/smallwikiapp-walk/linting/) and
[docs](https://rahuldave.com/smallwikiapp-walk/docs/).

## step-00 The project

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

```bash
just setup
```

The tutorial starts at step-00, so step-00 has no moves. `uv init --package --python 3.13 --name wikiapp` made
the shape of the project:

- `pyproject.toml`
- `src/wikiapp/__init__.py`, with a function `main`
- `.python-version`, with the Python version

Then the author changed the project by hand. `main` moved to `src/wikiapp/console.py`. `pyproject.toml` got a
description, an author and a licence, and it names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`. The author also wrote the justfile, the README, `.gitignore` and `LICENSE` by hand.

`just setup` runs `uv sync --locked`. The command makes `.venv` with Python 3.13, from `.python-version`. It
installs exactly the packages that the lockfile names. Here, the only package is `wikiapp` itself.

```bash
cat pyproject.toml
```

The line under `[project.scripts]` makes `wikiapp` a command. The name is on the left. The function is on the
right, `main` in `src/wikiapp/console.py`. For now, `main` prints one line.

```bash
uv run wikiapp
cat src/wikiapp/console.py
```

The justfile is the interface of the project. `just` lists the tasks, and `just --show setup` shows the recipe
behind one task. `just help setup` shows the same recipe. Most steps add recipes to the justfile.

```bash
just
just --show setup
just --show help
just help setup
```

## step-01 A random page

[The code at step-01](https://github.com/rahuldave/smallwikiapp/tree/step-01)

```bash
just setup
```

The moves of step-01 add these things:

- the two packages that the command needs
- a request to Wikipedia for a page
- a header that Wikipedia now asks for
- the option `--version`

### step-01.1 click and requests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e) shows what the move changes.

Now we add two packages, click and requests, to the dependencies of wikiapp. click makes command lines.
requests gets pages over HTTP.

Read the change of `pyproject.toml`.

The move changes these files:

- `pyproject.toml`: 4 lines added, 1 removed; the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: 176 lines added; the exact version of each, and of every package they need.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
  - look at: `"click>=8.5.0",`
- [`uv.lock`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/uv.lock), [its change](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e#diff-84321598744d84dbee2318e634c74c9aae39a1c253f1c4bd17ebf9ef2f807b11): the exact versions, for every platform.

The change of `pyproject.toml`:

```diff
@@ -7,7 +7,10 @@ license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.13"
-dependencies = []
+dependencies = [
+    "click>=8.5.0",
+    "requests>=2.34.2",
+]
 
 [project.scripts]
 wikiapp = "wikiapp.console:main"
```

The change of `uv.lock`:

```diff
@@ -2,7 +2,183 @@ version = 1
 revision = 3
 requires-python = ">=3.13"
 
+[[package]]
+name = "certifi"
+version = "2026.7.22"
+source = { registry = "https://pypi.org/simple" }
+sdist = { url = "https://files.pythonhosted.org/packages/a3/c2/24167ea9858356b47a87a50d39908bfdb72ceeefe0041586e704e5376b3a/certifi-2026.7.22.tar.gz", hash = "sha256:741e2c3b351ddf169a738da9f2c048608ff7f2c5cc02f1ebc6b118bb090d5d55", size = 138112, upload-time = "2026-07-22T03:35:12.644Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl", hash = "sha256:62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775", size = 136983, upload-time = "2026-07-22T03:35:11.276Z" },
+]
+
+[[package]]
+name = "charset-normalizer"
+version = "3.5.2"
+source = { registry = "https://pypi.org/simple" }
+sdist = { url = "https://files.pythonhosted.org/packages/33/1c/f41d4e74c28ab327ff3acd36053f7ea506c55872d7a90b0fa71aa3ab0c89/charset_normalizer-3.5.2.tar.gz", hash = "sha256:39de2a259fc954455c57274dc94c79d5842774e1247a016aff30bc0efed0f4ef", size = 172659, upload-time = "2026-09-30T04:39:23.398Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/c5/34/68292d68512768591aaff07c59bb53ee31341c87759433a859c4641a50c2/charset_normalizer-3.5.2-cp313-cp313-android_24_arm64_v8a.whl", hash = "sha256:ed905975ab14056a2e5eb1c376cb2e1ebc5396baf84163939c518556fccde9f5", size = 225946, upload-time = "2026-09-30T04:35:55.313Z" },
+    { url = "https://files.pythonhosted.org/packages/e3/80/bee0b01b90ccd5322ae1d0abb33fab1bd95b7c2eadaf02aeccf22e04ee83/charset_normalizer-3.5.2-cp313-cp313-android_24_x86_64.whl", hash = "sha256:a66c3bc5ab1f0ff2164fc9965ddd611ff0802173f4b9d24554c563f6ab7e1d6e", size = 238619, upload-time = "2026-09-30T04:35:56.863Z" },
+    { url = "https://files.pythonhosted.org/packages/78/6e/60ce52a85a7fd631ae8482ae6d74521014ca2f255892679484dc04d7ef56/charset_normalizer-3.5.2-cp313-cp313-ios_13_0_arm64_iphoneos.whl", hash = "sha256:d2374b62878abb00cd8309b32af6c0b715cd02dec0ca74ef12e5069bdc64144a", size = 206701, upload-time = "2026-09-30T04:35:58.639Z" },
+    { url = "https://files.pythonhosted.org/packages/36/8c/71aafad23f971afc84c2b295bc0c560739ce1dac558aad9fec22e39f3639/charset_normalizer-3.5.2-cp313-cp313-ios_13_0_arm64_iphonesimulator.whl", hash = "sha256:d376bbd28b3a8999db1a103b3b388aee6f1ddeb3e51bc2172993efdcd86e064d", size = 210506, upload-time = "2026-09-30T04:36:00.147Z" },
+    { url = "https://files.pythonhosted.org/packages/91/da/3c5a7798c046df7d2d68ad653cf5b6c5a8bfee225055a843c6f2f42aac1a/charset_normalizer-3.5.2-cp313-cp313-macosx_10_13_universal2.whl", hash = "sha256:6045373d5a89a5ec71afde535db987ca28e76dfa276c2d4c818265b375d4b055", size = 366626, upload-time = "2026-09-30T04:36:01.77Z" },
+    { url = "https://files.pythonhosted.org/packages/e1/16/710ac3de2ee354e2bd1a9c94efe45a2d27b5c6ad39b2d6a905be2c094b6c/charset_normalizer-3.5.2-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:849df64e889b2e17230d58410a03dba311a65b163508fd33679b2b737d4b7858", size = 244624, upload-time = "2026-09-30T04:36:03.389Z" },
+    { url = "https://files.pythonhosted.org/packages/d6/39/45c7439f5b63d24f7d5b2a1d760f34af7628782d7144b4cc8ded45c2d4bc/charset_normalizer-3.5.2-cp313-cp313-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:15c44f7edfd477b06f517a5cc317fc1707edb9de2c865f43d4b6513907473234", size = 235731, upload-time = "2026-09-30T04:36:04.987Z" },
+    { url = "https://files.pythonhosted.org/packages/4d/34/38f3154785ce92e9f56eb226f4d35bdfae6b008480dd055f58837a89c810/charset_normalizer-3.5.2-cp313-cp313-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:a89012d6d5476ee112d20d998570ed58df2260a852afb1758809cd6900411d21", size = 270352, upload-time = "2026-09-30T04:36:06.412Z" },
+    { url = "https://files.pythonhosted.org/packages/04/f3/859f74e7babc977705026b30593b3be04049632a522fb7000f83c033d747/charset_normalizer-3.5.2-cp313-cp313-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:0c951d5e6dd9c2ff60609476752bee49da4206adde960ebc247766937f72e718", size = 267393, upload-time = "2026-09-30T04:36:07.865Z" },
+    { url = "https://files.pythonhosted.org/packages/4b/85/41d27f234b82e47c167a5f6c0f62501dc0c640585ff4aba79e08a390336a/charset_normalizer-3.5.2-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl", hash = "sha256:7218e8f32b0956cfcd048fd42d9d5779809745ca1d86113ca56f66e7ae1549c4", size = 254660, upload-time = "2026-09-30T04:36:09.248Z" },
+    { url = "https://files.pythonhosted.org/packages/58/ca/5d1a997587febe5b26d8daffe363b5c1a091cece19828eec6502fd09c5ef/charset_normalizer-3.5.2-cp313-cp313-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:a19a731138fc27d5682277d3b9df22855cea1239bce7fcec5f78f42ef2d1f3c3", size = 249996, upload-time = "2026-09-30T04:36:10.73Z" },
+    { url = "https://files.pythonhosted.org/packages/b3/1f/d1e78246f7ed60c8c8d606b4ac27f66ce49cc3e95f24893ccbeba9f77302/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_aarch64.whl", hash = "sha256:62603db9a7caa0802eaa28c1c46fecd7b3a263a774069c24c3c28c302448721c", size = 247028, upload-time = "2026-09-30T04:36:12.294Z" },
+    { url = "https://files.pythonhosted.org/packages/8e/37/eba316edd4f0c4d3a5d945924c4eeeae59abac4056aa815d8a4268f863a2/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_armv7l.whl", hash = "sha256:b6856554c4f44d79fc2307d5768854310a8f0096e501c75637542c82292b0429", size = 240562, upload-time = "2026-09-30T04:36:13.887Z" },
+    { url = "https://files.pythonhosted.org/packages/c8/8e/aaa037d40ca9ef045977f1a661048b1aa33f223adfce3452fe9be9f79d14/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_ppc64le.whl", hash = "sha256:1bc0baf5ef96b6ede57d47f4b8fe4d9d84019c3bfcbeb20a41edc6a6ee341f1f", size = 271699, upload-time = "2026-09-30T04:36:15.41Z" },
+    { url = "https://files.pythonhosted.org/packages/26/19/1c1c9f75974adf523b87f34b8a2adc5a435cd65916812bcbd0dfa45f9a29/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_riscv64.whl", hash = "sha256:56bc200a365efb37383b7852e4cc5898d3b2da5987289b543956cf8cad71018a", size = 252030, upload-time = "2026-09-30T04:36:16.839Z" },
+    { url = "https://files.pythonhosted.org/packages/bc/90/0660ef18e18df0a4d2a1a0edff7dfbba42d4e50ef2425557a5bb7051f77b/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_s390x.whl", hash = "sha256:2c9ad19a6cfcd5ea5c0d41161d22f9df1dcc277e9bef2751391334546a314c00", size = 268565, upload-time = "2026-09-30T04:36:18.468Z" },
+    { url = "https://files.pythonhosted.org/packages/79/ba/57adc269824e8658f1a0f97a9e514c247445a9632b3419b97e0ba37f16dc/charset_normalizer-3.5.2-cp313-cp313-musllinux_1_2_x86_64.whl", hash = "sha256:e243bd13217235fc7290c621941c3f5cc8b66e4872495be821d7436ba2fb838d", size = 257627, upload-time = "2026-09-30T04:36:19.938Z" },
+    { url = "https://files.pythonhosted.org/packages/9a/85/33abd4315c052d3d4f54c92b1ee49bfbc0dc7115a981e462a793b6d2ab87/charset_normalizer-3.5.2-cp313-cp313-pyemscripten_2025_0_wasm32.whl", hash = "sha256:a090bb2c68df85450502e3e20d665e3a5af9c65a84d6508ed477badd49166fd3", size = 143407, upload-time = "2026-09-30T04:36:21.376Z" },
+    { url = "https://files.pythonhosted.org/packages/4f/de/6435e18d1aaa5d910b896d551411c96af1f42a0c56c29afc2016c61ccc2e/charset_normalizer-3.5.2-cp313-cp313-win32.whl", hash = "sha256:2b7b3bbfb4fe8ef40600792d762fbaa9057559f9d3fad209525b7a22b99e91fd", size = 183207, upload-time = "2026-09-30T04:36:22.776Z" },
+    { url = "https://files.pythonhosted.org/packages/9c/76/b8ec57f4e9ee3253541abf95e4a462c0175fe8032dcd070f1f2421240942/charset_normalizer-3.5.2-cp313-cp313-win_amd64.whl", hash = "sha256:78456a747de8dc58360ffa581f30a002baf5aa28cb262536545e91f113ed7639", size = 206489, upload-time = "2026-09-30T04:36:24.306Z" },
+    { url = "https://files.pythonhosted.org/packages/3e/60/c647c6ae47480221e875ea5d743ff94946f7416e3c69415ab772928e8d32/charset_normalizer-3.5.2-cp313-cp313-win_arm64.whl", hash = "sha256:11912e4bb14baae7c5d8791aa55ba0a3a03ec6729073307b0f57270abaa713d3", size = 195501, upload-time = "2026-09-30T04:36:25.846Z" },
+    { url = "https://files.pythonhosted.org/packages/58/ca/7aa91362a2f77ac8e9e28a9b902a74f7d0e11a851ef0d27a74308da8cd90/charset_normalizer-3.5.2-cp314-cp314-android_24_arm64_v8a.whl", hash = "sha256:1afb975bd5d68d5ce9f6b6d44fdf2f7e34b895a35e95708a7a91b20a3b51d187", size = 226010, upload-time = "2026-09-30T04:36:27.669Z" },
+    { url = "https://files.pythonhosted.org/packages/a8/cf/ac8878d0322cf88a1aad4c7b147db32ca0bd806eb0060957b2e31486dbe6/charset_normalizer-3.5.2-cp314-cp314-android_24_x86_64.whl", hash = "sha256:bbbfc8e28816f19d7c0f1816664980c0a9875d01b27cdf8eedddb639d9e108ad", size = 239266, upload-time = "2026-09-30T04:36:29.434Z" },
+    { url = "https://files.pythonhosted.org/packages/c9/6d/9a08d7e0b29b7208e2c6c01dc56c8e0520e7c7beadbbfb024b58fd69c8a5/charset_normalizer-3.5.2-cp314-cp314-ios_13_0_arm64_iphoneos.whl", hash = "sha256:7967d08cf06dee78443b874f98c98036f624f3a4e73e11f9f64f5be4d25393cf", size = 206783, upload-time = "2026-09-30T04:36:30.872Z" },
+    { url = "https://files.pythonhosted.org/packages/82/44/b0aa350280e6ff5a5492d17cf10460dd39d5ee848f872f7ba2df10607f60/charset_normalizer-3.5.2-cp314-cp314-ios_13_0_arm64_iphonesimulator.whl", hash = "sha256:4c2b5031f63e331e3839b40aed2dd6f191e9c07edbde303e7876846ea1946995", size = 210449, upload-time = "2026-09-30T04:36:32.625Z" },
+    { url = "https://files.pythonhosted.org/packages/7c/8a/40db9aa9f5907bb0e6f8b6d64064bf8852fb33d4b813ff9414911df7647c/charset_normalizer-3.5.2-cp314-cp314-macosx_10_15_universal2.whl", hash = "sha256:fcff63213e8e6e47770541a4607175404f47cbb3ebea7b6058cc82d524a0e424", size = 367815, upload-time = "2026-09-30T04:36:34.197Z" },
+    { url = "https://files.pythonhosted.org/packages/7f/72/9c5e7707b57c8ddfa9ddf7b0b1d009d7fbab9e9e887d5b721060f37e307d/charset_normalizer-3.5.2-cp314-cp314-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:8d86d6fc60743dc916eb79e2eb1ec4818e21e427731543af40a3021851174a13", size = 247095, upload-time = "2026-09-30T04:36:35.803Z" },
+    { url = "https://files.pythonhosted.org/packages/83/09/71e453691e927de4ddf792770cfaab3f49d494e222f66ea5e404bbd5e39c/charset_normalizer-3.5.2-cp314-cp314-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:7a881931aa470808df94a8c380eed2bbbc76cd9dc622310f99665658c821eb6d", size = 233942, upload-time = "2026-09-30T04:36:37.407Z" },
+    { url = "https://files.pythonhosted.org/packages/9f/86/85c84e4da8b27dd409577d9437926ff581c5f9d3c66038dc68c1a526de51/charset_normalizer-3.5.2-cp314-cp314-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:8024d00c3faf3fc0c16e07a69f4405e8eac7cc0ab15f65fe6cf43827c4cf72b4", size = 273762, upload-time = "2026-09-30T04:36:38.904Z" },
+    { url = "https://files.pythonhosted.org/packages/92/08/564955a4b5f2ccb410ab480bbe8c6a18063ff27f2d35458731c4a5335df9/charset_normalizer-3.5.2-cp314-cp314-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:4d48f2d08b9de5864e2c8744d4461b862fb149a18274abc8b698c45975573438", size = 269514, upload-time = "2026-09-30T04:36:40.469Z" },
+    { url = "https://files.pythonhosted.org/packages/18/24/bad3ac4271589df29cf5ce2f5ae490518a5739358052bd0d61209e6fea54/charset_normalizer-3.5.2-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl", hash = "sha256:34276fd796040bf0993ab33a369aa572e6979c7aab225a88893667ad8eac8f7a", size = 255056, upload-time = "2026-09-30T04:36:42.02Z" },
+    { url = "https://files.pythonhosted.org/packages/d6/3e/350d89ad49916b86554d6f5f2d03ec1152148f87e5ff735106c6a03b1a36/charset_normalizer-3.5.2-cp314-cp314-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:0521c5665880b33d603717defa76c094048900010897909952397feb3039da56", size = 251311, upload-time = "2026-09-30T04:36:43.577Z" },
+    { url = "https://files.pythonhosted.org/packages/56/5b/4970a2d154df502e133402906dd04e3ae7cada7b3011283c88d0479a2585/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_aarch64.whl", hash = "sha256:eff0ac9dbe711a4aee69bf04a83896aa9b85f19641264053a9f6d48573abb7dd", size = 250190, upload-time = "2026-09-30T04:36:45.185Z" },
+    { url = "https://files.pythonhosted.org/packages/88/8c/f1a91bddc8fb47c2889e29ea7ea49a194eb0d9868675d786806519c00d76/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_armv7l.whl", hash = "sha256:1503bccbeb36d5527790c3930327704c39af22de3112f1b1666a9f3ce15ee204", size = 237098, upload-time = "2026-09-30T04:36:46.689Z" },
+    { url = "https://files.pythonhosted.org/packages/24/0e/bb5dace3cc7e79068425386a6589c19b5a2ab5fefc2a46abea6919683332/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_ppc64le.whl", hash = "sha256:52aa6992700996af31f375de0c6bacd402b0097fe40b53c426b9f51a90ebabc7", size = 274228, upload-time = "2026-09-30T04:36:48.31Z" },
+    { url = "https://files.pythonhosted.org/packages/9d/79/b849ad523017ea9f5a45581bbebed91439e0cf42fd2860a6f64e358eb5a6/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_riscv64.whl", hash = "sha256:e09a3942ecbdee5cce73ea9d42da82b81b72ac1bf031ce069b93b5adf4eac8cd", size = 252401, upload-time = "2026-09-30T04:36:50.091Z" },
+    { url = "https://files.pythonhosted.org/packages/89/8c/75469d690cf47200bce8f6cad7655724fc23148e147abfc5ce78b5f65863/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_s390x.whl", hash = "sha256:c7c9ab723cde841fefb34efbad91e87f00a674b1fe1cd0784fde742bf2c154dc", size = 271846, upload-time = "2026-09-30T04:36:51.719Z" },
+    { url = "https://files.pythonhosted.org/packages/26/cd/6d52d3c7437cdcf2e310ce9f28f282e733d4ef60ed19105d1819c356255f/charset_normalizer-3.5.2-cp314-cp314-musllinux_1_2_x86_64.whl", hash = "sha256:ddc7dacc8ece3a182e7f15cb862d1fd616b46d076cb1ae9dd232b2c38b655874", size = 258151, upload-time = "2026-09-30T04:36:53.234Z" },
+    { url = "https://files.pythonhosted.org/packages/f7/4c/070b38bdb5f49a70199fce923ec0726a49536a63ab262abbfcaaf351110b/charset_normalizer-3.5.2-cp314-cp314-pyemscripten_2026_0_wasm32.whl", hash = "sha256:ee43c17b173d46a3212baa6ead3ae258eeabdae48c263a01ccf0218c366dd655", size = 143570, upload-time = "2026-09-30T04:36:54.816Z" },
+    { url = "https://files.pythonhosted.org/packages/81/84/9ebfc8ed6c8c4fcd8e726ff6bf220cc8deb3966e31dce9be8dd8aa017e64/charset_normalizer-3.5.2-cp314-cp314-win32.whl", hash = "sha256:4f87960d57feabfb618e4e0af6e7371645fa26a277860739d6e5d6e0012c92f0", size = 186412, upload-time = "2026-09-30T04:36:56.643Z" },
+    { url = "https://files.pythonhosted.org/packages/d1/78/5ed86f743d4bc350db307e7636419a0a5ee1d91806d30c7f667bd5c80dae/charset_normalizer-3.5.2-cp314-cp314-win_amd64.whl", hash = "sha256:e4e81e09c1578b8df602e3db08b0b3ea0a6947ad612f52bf8dc5ea8d47691f0c", size = 210965, upload-time = "2026-09-30T04:36:58.205Z" },
+    { url = "https://files.pythonhosted.org/packages/53/94/a3a7698e9b1a395e1eb99ccd9a324be9347973bff4e72db2a06496d7cd27/charset_normalizer-3.5.2-cp314-cp314-win_arm64.whl", hash = "sha256:80d02b6f04e92601a081dd97b23d3128033098bff5d35d392ddcc0476ea11253", size = 200406, upload-time = "2026-09-30T04:36:59.764Z" },
+    { url = "https://files.pythonhosted.org/packages/c1/48/c5dd00d5ef7791f02666de250a5bb6071e29b7e133cf4b835800b6d3bc27/charset_normalizer-3.5.2-cp314-cp314t-macosx_10_15_universal2.whl", hash = "sha256:dca9ab98072a5a54ebacebdc45f53e645336b320c667410b061be1ca588ae709", size = 396871, upload-time = "2026-09-30T04:37:01.543Z" },
+    { url = "https://files.pythonhosted.org/packages/12/c8/8379554b42e8368161d898476686947a0fdbd3e8865170d7909dcabfdee8/charset_normalizer-3.5.2-cp314-cp314t-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:f0aa869112ef88429ae17820d99c3dd9504c9e9c671d3c246f3d7442cb051084", size = 249711, upload-time = "2026-09-30T04:37:03.111Z" },
+    { url = "https://files.pythonhosted.org/packages/4a/eb/2ddb1035d17320caa9f41682935123a9a250277b261c3efc86b2d2a21343/charset_normalizer-3.5.2-cp314-cp314t-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:c0afc6800ba57ccc350374c5bd6150419915d95ce93cdbab2d783d75eaf30ecb", size = 231146, upload-time = "2026-09-30T04:37:04.721Z" },
+    { url = "https://files.pythonhosted.org/packages/4a/24/2ecb4bde104322cd7859d6594fcfa74649f8d90b3221c9feecbef149875b/charset_normalizer-3.5.2-cp314-cp314t-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:7dcd882da75ef9adf94903b1e3b9419e8aa8fb4c7396822b834b9ef7fb96954f", size = 271552, upload-time = "2026-09-30T04:37:06.295Z" },
+    { url = "https://files.pythonhosted.org/packages/3f/98/9d5f6ebc3aee9fef5d30b4aff11fb2ab7a1222b4064f8ef2c7c87cde217a/charset_normalizer-3.5.2-cp314-cp314t-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:2e06a3a98f916dd41d27f3105e02e7a40181c98c94b9158733d03a6f80506c09", size = 269810, upload-time = "2026-09-30T04:37:07.905Z" },
+    { url = "https://files.pythonhosted.org/packages/09/e1/a3b06a10461b1b7628853c934c644e03bc28e42767116afb52f19a56519b/charset_normalizer-3.5.2-cp314-cp314t-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl", hash = "sha256:6bd128f206a7752ae1f2ab6c61bf8a24ba28913a10df8b14c2637b973ff97a80", size = 259845, upload-time = "2026-09-30T04:37:09.554Z" },
+    { url = "https://files.pythonhosted.org/packages/fd/d3/6f561f74a296cf27d61775a1dc665ad13f3bff6a798810ca05907f37a7c4/charset_normalizer-3.5.2-cp314-cp314t-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:c8f3d67aeaf55f017982b73683f0e7342ba2f6635a78f69ce89ebb26aa411e5c", size = 252825, upload-time = "2026-09-30T04:37:11.274Z" },
+    { url = "https://files.pythonhosted.org/packages/26/9f/69e13ca3b18f43e0eafcd34c04a45b732ae22a43b54a5fc9e119103356eb/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_aarch64.whl", hash = "sha256:fe9753dfee015c570d73df76f899f18444d41388bffcde097deba51c4fadbb9f", size = 252659, upload-time = "2026-09-30T04:37:12.941Z" },
+    { url = "https://files.pythonhosted.org/packages/73/a9/ace29806a0dae18939919c76ba526472d83214afa101105fabff2cf30625/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_armv7l.whl", hash = "sha256:92888bb3187c5ba50500b00b3b310c9f2c651709d28036077680cb5255450a03", size = 238819, upload-time = "2026-09-30T04:37:14.659Z" },
+    { url = "https://files.pythonhosted.org/packages/f8/c1/6116d52a2e3311ec80f21f5fb5e17b27405f10b9608af8f6e69516841a1b/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_ppc64le.whl", hash = "sha256:d008d90a7f2471519aef0c90dfbe73b3e6e4d5e66ac48e19154c17e89e98b604", size = 272973, upload-time = "2026-09-30T04:37:16.346Z" },
+    { url = "https://files.pythonhosted.org/packages/19/aa/9955c7e93bba10a9c7e8f7a5031b7ced66f3a1883a55c00712b8d5850ff3/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_riscv64.whl", hash = "sha256:31f3930700408d211f13378ccbe1c40845d8da54bd0681fac3a9b5aae81c7aa8", size = 253692, upload-time = "2026-09-30T04:37:18.212Z" },
+    { url = "https://files.pythonhosted.org/packages/bb/33/2a6ae7fdc1b10cb581cef91addd8cdfc5f40d50abb5702309369d5834579/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_s390x.whl", hash = "sha256:2a925889534b3748302dae5dead07cc13480de1dac3aea80a941b729b471ef93", size = 268757, upload-time = "2026-09-30T04:37:19.877Z" },
+    { url = "https://files.pythonhosted.org/packages/a2/22/80992720a0282cd39bba1db35868e6b9c22f41281160143a836544bc1d8a/charset_normalizer-3.5.2-cp314-cp314t-musllinux_1_2_x86_64.whl", hash = "sha256:f5ec61164adcec446f8969a3358ec3f9b26bbda3b9213e5586d219afa8df2915", size = 262220, upload-time = "2026-09-30T04:37:21.583Z" },
+    { url = "https://files.pythonhosted.org/packages/92/9f/181fd07e1bffea1d95cd80c84ac537354f50699c22cfc4d3c02b6fc16208/charset_normalizer-3.5.2-cp314-cp314t-win32.whl", hash = "sha256:598a11a2c7ebaa5334bf698bf29568c9c390abac6a154d8170fedecd1cea38c5", size = 197797, upload-time = "2026-09-30T04:37:23.235Z" },
+    { url = "https://files.pythonhosted.org/packages/49/1c/25d8415ec1c4f2f41f1680435e4c87cfb378ff2f677d950946f2a45d0632/charset_normalizer-3.5.2-cp314-cp314t-win_amd64.whl", hash = "sha256:7fdde2c9fd9e3eca40631e024664cf2584272cc8f96308cbe5fdfc930f51d8bc", size = 222765, upload-time = "2026-09-30T04:37:24.891Z" },
+    { url = "https://files.pythonhosted.org/packages/3e/b4/46b48f013dadfc0d0d33b375438e31bdf5a989dc68389c6bf627054d4df9/charset_normalizer-3.5.2-cp314-cp314t-win_arm64.whl", hash = "sha256:d1befeed746d247c81127bb14de9dc3d30edb6e5976d34f83f86ed262b1d9105", size = 210985, upload-time = "2026-09-30T04:37:26.634Z" },
+    { url = "https://files.pythonhosted.org/packages/ca/e9/34e597dee616d0b8ee4b34d29399e85c2204ade174157a48505d42baa4ff/charset_normalizer-3.5.2-cp315-cp315-macosx_10_15_universal2.whl", hash = "sha256:87475fabc8d9996fd9c27debb395e642e8c838d78a00b6e932227a0e06b81e26", size = 367676, upload-time = "2026-09-30T04:37:28.329Z" },
+    { url = "https://files.pythonhosted.org/packages/60/9f/a5d1c91c0263745e2cd344c5a4415d787c575501ab1d449f1148ac6b495d/charset_normalizer-3.5.2-cp315-cp315-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:9409a8bf35cf78353942504b24a57de3d75b708997a1e4bd8db71ac8633ce364", size = 248414, upload-time = "2026-09-30T04:37:30.167Z" },
+    { url = "https://files.pythonhosted.org/packages/26/79/e697f77464748a3ee3cf490c83d592459400d4898380d66c38366b03080c/charset_normalizer-3.5.2-cp315-cp315-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:498dc3188ca05a68231ac3fdbfc7f57eb67e1343c30e0fea17f8218c1599b253", size = 244775, upload-time = "2026-09-30T04:37:31.964Z" },
+    { url = "https://files.pythonhosted.org/packages/ca/87/3d42a42e18ea066e2513936fd678a00696e77878b5ae04528976abdbcb83/charset_normalizer-3.5.2-cp315-cp315-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:e242bb1c5e76e97dfa9e7f209a71e93a01d7f19ffdd5cfbb2e2d55b4f08f8ab0", size = 273877, upload-time = "2026-09-30T04:37:33.661Z" },
+    { url = "https://files.pythonhosted.org/packages/c3/76/8a28136f3938ba9836f84280ce0c4d61ed1cf15a036b2034900c62634162/charset_normalizer-3.5.2-cp315-cp315-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:def79fa35ef0cef8d2accec024f4fdc7ead3012ff02f5215c783f39f03ef8cfc", size = 269455, upload-time = "2026-09-30T04:37:35.573Z" },
+    { url = "https://files.pythonhosted.org/packages/a0/a1/4fbf5d0f0f1b2a080474c1cf9a2f12c4c6531bb0e8ba591055e846d2b4e9/charset_normalizer-3.5.2-cp315-cp315-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl", hash = "sha256:3df041de8887954562c9b261cba85ca0e9ded74048daf125f45edcfaa4832229", size = 257336, upload-time = "2026-09-30T04:37:37.397Z" },
+    { url = "https://files.pythonhosted.org/packages/ba/a2/8b50aa320adb880ad579518e6f718f24944804b42a88b83d267d5d444125/charset_normalizer-3.5.2-cp315-cp315-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:04851f73ae72b8413dddadb16a49dfee95263553741fd42d546f7d66907e6be5", size = 257584, upload-time = "2026-09-30T04:37:39.522Z" },
+    { url = "https://files.pythonhosted.org/packages/a5/57/50e3fed84e175f40349bd0da7a4fce94c87f0378f52d74f511d89e0bdc20/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_aarch64.whl", hash = "sha256:183b88127acdb4fabe59d951ab424faf1af7b63cdbb5f776186c1ea2ffcaed98", size = 251854, upload-time = "2026-09-30T04:37:41.23Z" },
+    { url = "https://files.pythonhosted.org/packages/d6/54/f7fbb3493c9f49091213b9c2d6dd65800696f1ce1a3f196a4205f50417b1/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_armv7l.whl", hash = "sha256:16fa0eccf81304b79c5cd87f9271c3b85dd9dd99245e4422ae9c0dd45e0f99d3", size = 248767, upload-time = "2026-09-30T04:37:42.883Z" },
+    { url = "https://files.pythonhosted.org/packages/d9/37/b3a6385acc5a1e45b39ae9c90bfb9cf838a09b9dd37ef2740ab4c6b4a2eb/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_ppc64le.whl", hash = "sha256:7441d755b7ab94f8d4eb3e43ec05482d760842fd263d003a99102d742cd835e2", size = 274479, upload-time = "2026-09-30T04:37:44.658Z" },
+    { url = "https://files.pythonhosted.org/packages/89/44/809913e2cfd279e635a9294fdbbfb1b1dc62a8189d473d561f649fce98d8/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_riscv64.whl", hash = "sha256:ca403d7e4798f525fdfc78e258820419cbbd0f0ecbab9de7840e3c017cf6b8cf", size = 258310, upload-time = "2026-09-30T04:37:46.529Z" },
+    { url = "https://files.pythonhosted.org/packages/af/a2/f28400ab13359d91bd39179df8e149376b9bf36588e739a3a4f9de2b84b2/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_s390x.whl", hash = "sha256:df29a0a7107f7011e77f4eebdddec4c7331e24d787a0b21a46d63bdf7445da95", size = 271100, upload-time = "2026-09-30T04:37:48.399Z" },
+    { url = "https://files.pythonhosted.org/packages/e9/89/9bab37955edf0adb3b66f8a3a6617d9f2f487e0d56f295a6a286cb640aa6/charset_normalizer-3.5.2-cp315-cp315-musllinux_1_2_x86_64.whl", hash = "sha256:f3c96f633825733f735c5a9cf21d21a257d8e1edf0b1cee0a064b9c424ca0f7d", size = 259936, upload-time = "2026-09-30T04:37:50.023Z" },
+    { url = "https://files.pythonhosted.org/packages/23/b5/4459e08d45a679f903d50fea08bc52cfa728cca4d7bd02c757b5e5abda2e/charset_normalizer-3.5.2-cp315-cp315-win32.whl", hash = "sha256:281cb91036248400f4cc957495cccd44c275c2e0c5854f7e45ac5cf7dc193847", size = 186301, upload-time = "2026-09-30T04:37:51.722Z" },
+    { url = "https://files.pythonhosted.org/packages/98/e8/55d5fd3935b4bce6da4fe0df61898e8c82653e317e677bd58aceb9c60f13/charset_normalizer-3.5.2-cp315-cp315-win_amd64.whl", hash = "sha256:89b53f3cda69831909888e0494f4fa0bcd3537e3e138dabeb620bd6ad946bae8", size = 210858, upload-time = "2026-09-30T04:37:53.427Z" },
+    { url = "https://files.pythonhosted.org/packages/a9/5b/974423c2fd8e524c7a7f64318c1e02240ef954912fa2b4d70344107b9c68/charset_normalizer-3.5.2-cp315-cp315-win_arm64.whl", hash = "sha256:6be488a102b8cf28d0391d8c4ba7748938ae28b78ad901f8585520fca33ead1a", size = 200309, upload-time = "2026-09-30T04:37:55.015Z" },
+    { url = "https://files.pythonhosted.org/packages/ee/f9/00ee0195db1013d8f7c416fd770fbeb560bb46eb2e36b054d05cb56f6cfa/charset_normalizer-3.5.2-cp315-cp315t-macosx_10_15_universal2.whl", hash = "sha256:915563965d418f986e7e145accc592eae9e1a1be3566ff98a05d7a9ec42a76e1", size = 395343, upload-time = "2026-09-30T04:37:56.743Z" },
+    { url = "https://files.pythonhosted.org/packages/04/3a/c00b50e94c964cf934c7899cd47c97952fc11dad71cc5884b3c61795b09b/charset_normalizer-3.5.2-cp315-cp315t-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:65cd72beeeca9d3aaea1201e5923859f308f952f9c71de93f06063c79f0f7a3b", size = 250114, upload-time = "2026-09-30T04:37:58.607Z" },
+    { url = "https://files.pythonhosted.org/packages/50/27/d102dc880bbcffd0479ab64dfc1fb96777a854355a55e2bda72a71efadcb/charset_normalizer-3.5.2-cp315-cp315t-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:b7fd005a73d9e657273b7a10dc71a9e03c8fb9ee6999798d6918ce095b81ac7f", size = 239997, upload-time = "2026-09-30T04:38:00.511Z" },
+    { url = "https://files.pythonhosted.org/packages/a5/4a/bf7ef45794dd293fab5f98a9309817977fbb845b9998f171b8cc5d8437a3/charset_normalizer-3.5.2-cp315-cp315t-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:e54da4baf05720032d527874d40b65fa4d7e5c6c6a43d0c3adbeffcaf275a2b3", size = 272313, upload-time = "2026-09-30T04:38:02.509Z" },
+    { url = "https://files.pythonhosted.org/packages/e8/ee/008a2837737991474c5754bb3191010007663860979701990982a502cbaf/charset_normalizer-3.5.2-cp315-cp315t-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:124fbf1a8ff966d87ae05bb8bd45a71f966055ed8bba320d0c7cf450bc5f4d0e", size = 269986, upload-time = "2026-09-30T04:38:04.435Z" },
+    { url = "https://files.pythonhosted.org/packages/93/ad/bd74a283940dc910c5b14f8e4f80a248082bc9c0fcbe1f54530cb6d9cc5e/charset_normalizer-3.5.2-cp315-cp315t-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl", hash = "sha256:28b4f0d66fb834ff90f28209ac7bce77868c45d8c93e26f906709d9b7c2e1af9", size = 260202, upload-time = "2026-09-30T04:38:06.549Z" },
+    { url = "https://files.pythonhosted.org/packages/8a/7b/ed341c66f69f688723501fac752be3d63c7159ca0d0d4174fc611e5710bb/charset_normalizer-3.5.2-cp315-cp315t-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:58ca3755ee7ff7f59b57789ec9833c9de9ea275405cdd240eda1f193112e398a", size = 259083, upload-time = "2026-09-30T04:38:08.311Z" },
+    { url = "https://files.pythonhosted.org/packages/cc/9d/e41588b777965e5031a43128a1e96173ebb35ac75fc53ec3b517e7c21cd4/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_aarch64.whl", hash = "sha256:443eae2bf318abeaf6f15d785138f71fd6de770e99a92158b8b814265e079115", size = 253081, upload-time = "2026-09-30T04:38:10.402Z" },
+    { url = "https://files.pythonhosted.org/packages/81/35/b761eb6d8c1eb218b9b42b9b4d5ac902afdc399fb6dac6f9a9aac7bda589/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_armv7l.whl", hash = "sha256:58f361dcbab699cf8f42db3f47c8e7fd1036f138c23a5d08de9fde5f425a730c", size = 248712, upload-time = "2026-09-30T04:38:12.317Z" },
+    { url = "https://files.pythonhosted.org/packages/4d/2c/147169a041b747759f37405c0a97157e8e92de967968373101ff14915cba/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_ppc64le.whl", hash = "sha256:1b4cbc7c3491ccb4aa17fcd8165649d01cf39f76de1696da8631b5f71b85401d", size = 274176, upload-time = "2026-09-30T04:38:14.138Z" },
+    { url = "https://files.pythonhosted.org/packages/f0/2d/0ff8db0d373ba8538db686db11cd7e8912031490b9e4f383b41912e8d594/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_riscv64.whl", hash = "sha256:ba0b1d2620edf869789c3879223f52bf2afc5d31b3cb47cc57b3a12c05e2aa9d", size = 259413, upload-time = "2026-09-30T04:38:15.841Z" },
+    { url = "https://files.pythonhosted.org/packages/8a/8e/b4a085fb47c9d3a7e43576a4784fdd8fe23f907514a972de8086edaf7a48/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_s390x.whl", hash = "sha256:5e2b6b57e9733d39f0c9fd3185efa6b8e29652c4cd8fe94180272cf6ed9a78c4", size = 269434, upload-time = "2026-09-30T04:38:17.626Z" },
+    { url = "https://files.pythonhosted.org/packages/83/1c/d8d8d7322a7c3eecdf3237a4a419cf41d2eaad8e006ce7dfdd9d4c8fa2eb/charset_normalizer-3.5.2-cp315-cp315t-musllinux_1_2_x86_64.whl", hash = "sha256:51cf45226a9b588d0d2b4880c62d686934b63ab0bd79ca23ab0e9762eb27441b", size = 262716, upload-time = "2026-09-30T04:38:19.214Z" },
+    { url = "https://files.pythonhosted.org/packages/a0/16/0e4c6ba9b44e97a2da150e52d331e8f9c968b21b358fbffa6c856cebcd89/charset_normalizer-3.5.2-cp315-cp315t-win32.whl", hash = "sha256:5fb29fb8cd1a46c27a1bf9613ad5ec2599310d46b4025d9556404a6b6a292800", size = 197159, upload-time = "2026-09-30T04:38:21.037Z" },
+    { url = "https://files.pythonhosted.org/packages/be/33/e90bc2b1374f7f36ef106f56620de5a783907e19ca857efe2277e31cac3e/charset_normalizer-3.5.2-cp315-cp315t-win_amd64.whl", hash = "sha256:a192e2c40070d92c3ccf777e3a5c4ff515573cd2bb7ed0c537fdadbbec5bbf21", size = 221322, upload-time = "2026-09-30T04:38:22.886Z" },
+    { url = "https://files.pythonhosted.org/packages/66/89/dfa6dcb08c200b7830ab56439e8c1890f2971d51aafbb3937894a2e7fcfc/charset_normalizer-3.5.2-cp315-cp315t-win_arm64.whl", hash = "sha256:749e97e1b32313717a565abbe321bc2190bc8b35f1a67e4cdbc7c56c8d8ffe58", size = 209192, upload-time = "2026-09-30T04:38:24.648Z" },
+    { url = "https://files.pythonhosted.org/packages/8c/ab/176fbfd5b64939c55d652366aa5b9ef1d767af207a3aa6ebeb0d226c484d/charset_normalizer-3.5.2-cp37-abi3-macosx_10_9_universal2.whl", hash = "sha256:4275811936e2f06feff5e598fb42a1b7ae852da8e39605211892b56b81a34efd", size = 331815, upload-time = "2026-09-30T04:38:26.216Z" },
+    { url = "https://files.pythonhosted.org/packages/7e/84/371eac6b30bdbcbf2d632a1a01809103459216fcaae61b8b8d922c1bfb8a/charset_normalizer-3.5.2-cp37-abi3-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl", hash = "sha256:1c50fe28bbc2ced33386f298650d91218076c05420e6cbd790b913adc41659e7", size = 253276, upload-time = "2026-09-30T04:38:28.032Z" },
+    { url = "https://files.pythonhosted.org/packages/43/6f/c4fbae58febff71709c51bc7e18fdfa55341dc382704740f9f0cbf03817b/charset_normalizer-3.5.2-cp37-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl", hash = "sha256:d19fbd981a488e22cd04883659ca6b08f50b5974f9fd7c95655ef6a043e5893f", size = 241239, upload-time = "2026-09-30T04:38:29.732Z" },
+    { url = "https://files.pythonhosted.org/packages/61/71/458c3f42164a07d0c5210798e9e704b39e540a6793b05aba67f3a35243a9/charset_normalizer-3.5.2-cp37-abi3-manylinux2014_armv7l.manylinux_2_17_armv7l.manylinux_2_31_armv7l.whl", hash = "sha256:0fed1d06615f022ee3b13caf5e8b180cfea32bb2c5aded8a9d44277afc040f93", size = 231121, upload-time = "2026-09-30T04:38:31.462Z" },
+    { url = "https://files.pythonhosted.org/packages/09/54/ab9e89367076f6331bb6c65c4bf14a5361fa5191cb6561bf534f18504e1b/charset_normalizer-3.5.2-cp37-abi3-manylinux2014_ppc64le.manylinux_2_17_ppc64le.manylinux_2_28_ppc64le.whl", hash = "sha256:838dcc90063569a0448120554591a1d6c4a4ffe11babf048908793154ab86ade", size = 260350, upload-time = "2026-09-30T04:38:33.239Z" },
+    { url = "https://files.pythonhosted.org/packages/7c/c1/061431ecc688d9d76602502cb57cc01e691e682c18f1beb45f9673b5bbd2/charset_normalizer-3.5.2-cp37-abi3-manylinux2014_s390x.manylinux_2_17_s390x.manylinux_2_28_s390x.whl", hash = "sha256:2ce45c6627b22c47e390bc91a41c3d13032192e699fa0bea96e9671b373d69b0", size = 255430, upload-time = "2026-09-30T04:38:34.865Z" },
+    { url = "https://files.pythonhosted.org/packages/8d/1f/20c8949f0676f7ab811abdeb7f4d7f1cbc6e61ff20bef08b44edeb092bc8/charset_normalizer-3.5.2-cp37-abi3-manylinux_2_31_riscv64.manylinux_2_39_riscv64.whl", hash = "sha256:0774bf9bf620249fee3e0b8b9fd3065de213be30f3aa94ce2494b3b638949e26", size = 250612, upload-time = "2026-09-30T04:38:36.649Z" },
+    { url = "https://files.pythonhosted.org/packages/2b/9e/46f2fa4c431fc98c4ae76a8cb5bdca54e0341e3cfc3fcfd8e82740250818/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_aarch64.whl", hash = "sha256:1db38f4c5496827c1a501846d64d14c3b80c7e6714e406cd7dc36a9899fa1011", size = 242083, upload-time = "2026-09-30T04:38:38.26Z" },
+    { url = "https://files.pythonhosted.org/packages/bd/39/559be29a0c0f086e0bba6922babd38916cc5e0b58ced4de13ee01ea05508/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_armv7l.whl", hash = "sha256:304d8e4d493af723536393eee0c689eb7813f4a474c8b479dee63f1fdd98f621", size = 232738, upload-time = "2026-09-30T04:38:39.81Z" },
+    { url = "https://files.pythonhosted.org/packages/ff/6c/387b0e4f756a282831c1d9fc6aeb6c51ca4507ca202767c8de15ce9b12e2/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_ppc64le.whl", hash = "sha256:9b7f416ff0978e2f2249330527f0ad6fa02f4932e6199692d3b52da2048c19e4", size = 260703, upload-time = "2026-09-30T04:38:41.346Z" },
+    { url = "https://files.pythonhosted.org/packages/96/92/1fdf015f09ef449f50d3ac4b67c90887c9c318b727daa95cc4f866e6521d/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_riscv64.whl", hash = "sha256:01077390b03f7988f11d700a2194e69b119741a86b1a638b1db88891e3eced8e", size = 247622, upload-time = "2026-09-30T04:38:42.937Z" },
+    { url = "https://files.pythonhosted.org/packages/dc/3c/8e7b8a5671ad5d433669fb2a76f1a0164df2d9b1718b0206bc2a16d840cc/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_s390x.whl", hash = "sha256:7e841fb9010836c992c9f12fcbd43a831de93a5f726fc1ccd8ca1d0268c5014c", size = 257500, upload-time = "2026-09-30T04:38:44.604Z" },
+    { url = "https://files.pythonhosted.org/packages/b4/f0/45b579df5cabc1d5d53ea1cc35e8437d3ca768c0acccc7041517cb6fbb32/charset_normalizer-3.5.2-cp37-abi3-musllinux_1_2_x86_64.whl", hash = "sha256:9cae88599c7219005d879f98e5ed53341e9a122af585e1091200358a3003d2a0", size = 255100, upload-time = "2026-09-30T04:38:46.289Z" },
+    { url = "https://files.pythonhosted.org/packages/31/68/fdec18a343f5fb3f310588dd478b09ac4799e0b187dbade3a8cd776f03ef/charset_normalizer-3.5.2-cp37-abi3-win32.whl", hash = "sha256:01b0c0d2262a9e28e8484a278c7e1b5d650e3ac8cf2683d2967e25899f208bdf", size = 174499, upload-time = "2026-09-30T04:38:47.999Z" },
+    { url = "https://files.pythonhosted.org/packages/9d/8a/b618149cc5207943a0242068d7a27897f56a62947b5a039085f2a22029f8/charset_normalizer-3.5.2-cp37-abi3-win_amd64.whl", hash = "sha256:9f56f72050826f63dcee7a7f55b0a77168cb3bfc553fd405e7f8f9ece75a4036", size = 200092, upload-time = "2026-09-30T04:38:49.707Z" },
+    { url = "https://files.pythonhosted.org/packages/03/cf/4c66866fa9e2b1c78e3c911516d1de497a677b7ac60f1eceda74ce777ca3/charset_normalizer-3.5.2-cp37-abi3-win_arm64.whl", hash = "sha256:40ab6bffa02ae10a0581e6c198be7d2d8ca5c2a0c64e4ed3465d766df457573e", size = 294363, upload-time = "2026-09-30T04:38:51.312Z" },
+    { url = "https://files.pythonhosted.org/packages/fc/ad/d07d7862a62ffa6d79d68074d14823243dd235a77c45262acbf6adeb28bf/charset_normalizer-3.5.2-py3-none-any.whl", hash = "sha256:b6b751274acb69d77b3323d6b7dbaa3c7fdfc1eb829b7eb61d262f32e1af9685", size = 68872, upload-time = "2026-09-30T04:39:21.828Z" },
+]
+
+[[package]]
+name = "click"
+version = "8.5.0"
+source = { registry = "https://pypi.org/simple" }
+sdist = { url = "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz", hash = "sha256:ba0d2089de75ea0310e2dde03160e6ca10009947fb95a182f9b54021bb272e34", size = 382235, upload-time = "2026-08-26T13:33:14.56Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/58/50/6c0d534c5f134586a8e1ba4e330569e32f057e33372ae556463212fb4cd3/click-8.5.0-py3-none-any.whl", hash = "sha256:255bc9599cf7748b4b1a446ccc735421bd08a2ae529a8b88597d3de5664ee360", size = 125251, upload-time = "2026-08-26T13:33:12.928Z" },
+]
+
+[[package]]
+name = "idna"
+version = "3.20"
+source = { registry = "https://pypi.org/simple" }
+sdist = { url = "https://files.pythonhosted.org/packages/f5/08/8eea9d4b8302028f3abb2c0813953f7aec26d33b7a8960ed760e65ff29fa/idna-3.20.tar.gz", hash = "sha256:a7db850025b95ded1eae8a46181a1a6c56c92c96f0e2b005d9ff8dc0210cab44", size = 216463, upload-time = "2026-09-17T14:11:04.752Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/58/a2/bb081bab032533a855d44de1d56f8e8426114ff1ba5d1f07a438a0a654f8/idna-3.20-py3-none-any.whl", hash = "sha256:ab7ae7122974553370f0bdb919e1a960b2cd1bc1ef0276416d896db81c14582c", size = 69583, upload-time = "2026-09-17T14:11:03.168Z" },
+]
+
+[[package]]
+name = "requests"
+version = "2.34.2"
+source = { registry = "https://pypi.org/simple" }
+dependencies = [
+    { name = "certifi" },
+    { name = "charset-normalizer" },
+    { name = "idna" },
+    { name = "urllib3" },
+]
+sdist = { url = "https://files.pythonhosted.org/packages/ac/c3/e2a2b89f2d3e2179abd6d00ebd70bff6273f37fb3e0cc209f48b39d00cbf/requests-2.34.2.tar.gz", hash = "sha256:f288924cae4e29463698d6d60bc6a4da69c89185ad1e0bcc4104f584e960b9ed", size = 142856, upload-time = "2026-05-14T19:25:27.735Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl", hash = "sha256:2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0", size = 73075, upload-time = "2026-05-14T19:25:26.443Z" },
+]
+
+[[package]]
+name = "urllib3"
+version = "2.8.0"
+source = { registry = "https://pypi.org/simple" }
+sdist = { url = "https://files.pythonhosted.org/packages/e3/05/b17359e1cefb4f909b5e40b1b90a496d987258916dbbf88e842c729f510e/urllib3-2.8.0.tar.gz", hash = "sha256:63bf2ead4c879426ebf22ef2a781eeb4aa3b4ae798a0435506f8687fd5bb9b63", size = 458972, upload-time = "2026-09-15T19:29:36.253Z" }
+wheels = [
+    { url = "https://files.pythonhosted.org/packages/92/9d/c4e665119135114480843e7ab388fa94d8480650450e6f8e26b70d323a4c/urllib3-2.8.0-py3-none-any.whl", hash = "sha256:0cf3cae568d36aa9576b28dfb35f11328f1cb974ca7647d9475ebb86c75ac6e3", size = 135717, upload-time = "2026-09-15T19:29:34.577Z" },
+]
+
 [[package]]
 name = "wikiapp"
 version = "0.1.0"
 source = { editable = "." }
+dependencies = [
+    { name = "click" },
+    { name = "requests" },
+]
+
+[package.metadata]
+requires-dist = [
+    { name = "click", specifier = ">=8.5.0" },
+    { name = "requests", specifier = ">=2.34.2" },
+]
```

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0) shows what the move changes.

Now we make `main` ask Wikipedia for a random page, and print it.

`src/wikiapp/console.py` now has the first code of wikiapp, from 2024, with a docstring that says what the
command does. `@click.command()` makes `main` a command. The `main` of the original wikiapp had no `-> None`. The
`main` here keeps the annotation that `uv init` gave it at step-00.

- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.

`main` prints the title in green, and the summary wrapped to 70 columns.

Read the change of `src/wikiapp/console.py`.

The move changes one file:

- `src/wikiapp/console.py`: 17 lines added, 2 removed; `main` asks Wikipedia for a page and prints it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/a46ba5420b43d7ea47508ae393977935e7bd8bd0/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): a request, and two lines printed.
  - look at: `with requests.get(API_URL) as response:`

The change of `src/wikiapp/console.py`:

```diff
@@ -1,4 +1,19 @@
+import click
+import requests
+import textwrap
 
+API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+
+@click.command()
 def main() -> None:
-    """Print a line, until there is a page to print."""
-    print("Hello from wikiapp!")
+    """Print the title and summary of a random Wikipedia page."""
+    with requests.get(API_URL) as response:
+        response.raise_for_status()
+        data = response.json()
+        title = data["title"]
+        extract = data["extract"]
+        click.secho(title, fg="green")
+        click.echo(textwrap.fill(extract))
+
+if __name__=="__main__":
+    main()
```

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. Wikipedia now refuses a request whose User-Agent header is the default of
a library. requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb) shows what the move changes.

Now we send a User-Agent header with the request. The User-Agent header says who sends the request. The policy of
Wikimedia asks for the name of the program, its version, and a way to reach the person who runs it. In
`src/wikiapp/console.py`, a constant `USER_AGENT` under `API_URL` gives these three things.

Find `USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"` in the change of
`src/wikiapp/console.py`.

The move changes one file:

- `src/wikiapp/console.py`: 2 lines added, 1 removed; a constant `USER_AGENT`, and the request sends it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2dd3e2132565971092bffe6a438a36506f4161cb/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

The change of `src/wikiapp/console.py`:

```diff
@@ -3,11 +3,12 @@ import requests
 import textwrap
 
 API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL) as response:
+    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         data = response.json()
         title = data["title"]
```

```bash
uv run wikiapp
```

A title in green, and a paragraph. Each run prints another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c) shows what the move changes.

Now we let the command print its version. The package can read its own version from the installed package, which
has the version in `pyproject.toml`. `src/wikiapp/__init__.py` now sets `__version__` from the metadata of the
installed package. `src/wikiapp/console.py` imports `__version__`. The decorator `@click.version_option`, above
`def main`, gives the command the option `--version`.

Read the change of `src/wikiapp/__init__.py`, then the change of `src/wikiapp/console.py`.

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; `__version__`, from the installed package.
- `src/wikiapp/console.py`: 2 lines added; the option `--version`.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): the version, which Python reads when it imports the package.
  - look at: `__version__ = importlib.metadata.version(__name__ or __package__)`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): click's version option.
  - look at: `@click.version_option(version=__version__)`

The change of `src/wikiapp/__init__.py`:

```diff
@@ -0,0 +1,2 @@
+import importlib.metadata
+__version__ = importlib.metadata.version(__name__ or __package__)
```

The change of `src/wikiapp/console.py`:

```diff
@@ -1,4 +1,5 @@
 import click
+from wikiapp import __version__
 import requests
 import textwrap
 
@@ -6,6 +7,7 @@ API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
+@click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
     with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring.

## step-02 Tests, with mocks

[The code at step-02](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

The moves of this step add pytest and a first test, a recipe for the tests, and a fixture. The fourth move puts a
mock in place of Wikipedia, with a test of the title. The last three moves add three more tests, and coverage on
every run. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows what the move changes.

Now we install pytest, the tool that runs the tests. The tests need pytest, but the package does not. A person who
installs wikiapp should not get pytest. So pytest goes in a dependency group of its own, `test`. uv installs the
group `dev` by default, so `dev` includes `test`.

Read the change of `pyproject.toml`.

Next we write the first test, in `tests/test_console.py`, which runs the command and checks that it ends with exit
code 0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code
of the command.

Open `tests/test_console.py`, a new file.

The move changes these files:

- `pyproject.toml`: 6 lines added; the groups `test` and `dev`.
- `tests/test_console.py`: 8 lines added; the first test.
- `uv.lock`: 73 lines added; pytest and what it needs.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
  - look at: `dev = [{ include-group = "test" }]`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/tests/test_console.py): a test that runs the command and checks its exit code.
  - look at: `assert result.exit_code == 0`

The change of `pyproject.toml`:

```diff
@@ -15,6 +15,12 @@ dependencies = [
 [project.scripts]
 wikiapp = "wikiapp.console:main"
 
+[dependency-groups]
+test = [
+    "pytest>=9.1.1",
+]
+dev = [{ include-group = "test" }]
+
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
```

```bash
uv run pytest
```

The result is `1 passed`. The test asks the real Wikipedia, so it needs the network.

### step-02.2 The recipe `just test`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a) shows what the move changes.

Now we add a recipe to the `justfile`, `test`, which runs the tests. The words after `just test` go to pytest.
`"$@"` stands for those words, and the recipe gives each word to pytest whole. `just test help` shows the recipe.

Read the change of `justfile`.

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

The move changes one file:

- `justfile`: 6 lines added; the recipe `test`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/94970c50651566f11d5c9d017cb01004e240821a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `test *args:`

The change of `justfile`:

```diff
@@ -19,3 +19,9 @@ help *verb:
 [group('setup')]
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
+
+# Run the tests. Extra arguments go to pytest: just test -k title
+[group('quality')]
+[no-exit-message]
+test *args:
+    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

```bash
just --show test
just test
```

The result is the same, `1 passed`.

### step-02.3 The runner as a fixture

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534) shows what the move changes.

Now we move the `CliRunner` into a fixture, `runner`, which returns it. Each test of the command needs a
`CliRunner`. A fixture is a function that pytest calls for each test that names it as a parameter. So
`test_main_succeeds` takes the runner as its parameter.

Read the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 6 lines added, 2 removed; the fixture `runner`, and `test_main_succeeds` takes the runner from it.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/cd31b8a082b8c3ecf168413a21e06b9888480534/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture, and the test that names it.
  - look at: `def test_main_succeeds(runner):`

The change of `tests/test_console.py`:

```diff
@@ -1,8 +1,12 @@
 import click.testing
+import pytest
+
+@pytest.fixture
+def runner():
+    return click.testing.CliRunner()
 
 from wikiapp import console
 
-def test_main_succeeds():
-    runner = click.testing.CliRunner()
+def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

### step-02.4 A mock in place of Wikipedia

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5) shows what the move changes.

Now we replace `requests.get` with a mock in the tests. A test that needs the network fails on a train. Also, a
test cannot check the title of a random page. pytest-mock can replace `requests.get` with a mock for the length of
one test. It goes in the group `test`.

`mocker` is the fixture of pytest-mock. A new fixture, `mock_requests_get`, calls `mocker.patch("requests.get")`.
The call replaces the function, and puts it back after the test. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets what the mock returns when
the code calls `response.json()` inside the `with` block. The mock returns a page with the title Lorem Ipsum. A
new test, `test_main_prints_title`, checks that the command prints that title.

Read the change of `pyproject.toml`. Find `mock = mocker.patch("requests.get")` in the change of
`tests/test_console.py`.

The move changes these files:

- `tests/test_console.py`: 13 lines added; the fixture of the mock, and a test of the title.
- `pyproject.toml`: 1 line added; pytest-mock in the group `test`.
- `uv.lock`: 22 lines added, 2 removed; the exact version of pytest-mock.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture of the mock, and the new test.
  - look at: `mock = mocker.patch("requests.get")`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pytest-mock in the group `test`.
  - look at: `"pytest-mock>=3.16.0",`

The change of `tests/test_console.py`:

```diff
@@ -5,8 +5,21 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
+@pytest.fixture
+def mock_requests_get(mocker):
+    mock = mocker.patch("requests.get")
+    mock.return_value.__enter__.return_value.json.return_value = {
+        "title": "Lorem Ipsum",
+        "extract": "Lorem ipsum dolor sit amet",
+    }
+    return mock
+
 from wikiapp import console
 
+def test_main_prints_title(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert "Lorem Ipsum" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `pyproject.toml`:

```diff
@@ -18,6 +18,7 @@ wikiapp = "wikiapp.console:main"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-mock>=3.16.0",
 ]
 dev = [{ include-group = "test" }]
 
```

```bash
just test -k title -v
```

The output shows `test_main_prints_title PASSED`, without the network.

### step-02.5 Tests of the request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f) shows what the move changes.

Now we add two tests of the request to `tests/test_console.py`. A mock keeps a record of each call to it.
`test_main_invokes_requests_get` checks that the command calls `requests.get`, and `test_main_uses_correct_url`
checks the address. `call_args[0]` is the tuple of the positional arguments of the last call. Here it contains
only the address. The header is a keyword argument, in `call_args[1]`.

Read the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 8 lines added; two tests of the request.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the code makes the request, to the right address.
  - look at: `assert mock_requests_get.called`

The change of `tests/test_console.py`:

```diff
@@ -20,6 +20,14 @@ def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+def test_main_invokes_requests_get(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.called
+
+def test_main_uses_correct_url(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The result is `4 passed`.

### step-02.6 A test of a failed request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7) shows what the move changes.

Now we add a test, `test_main_fails_on_request_error`, to `tests/test_console.py`. It makes the mock raise, and
checks that a failed request ends the command with exit code 1. A mock can raise an exception as well as return a
value. If `side_effect` is an exception, a call to the mock raises it.

Find `mock_requests_get.side_effect = Exception("Boom")` in the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 5 lines added; a test that a failed request ends the command with exit code 1.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/16b52dc4f9ec6e997b6954efde180ba6d7f521c7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the mock raises.
  - look at: `mock_requests_get.side_effect = Exception("Boom")`

The change of `tests/test_console.py`:

```diff
@@ -28,6 +28,11 @@ def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
 
+def test_main_fails_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = Exception("Boom")
+    result = runner.invoke(console.main)
+    assert result.exit_code == 1
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The result is `5 passed`.

### step-02.7 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef) shows what the move changes.

Now we measure the coverage of the tests on every run. pytest-cov measures which lines of the code the tests run.
It goes in the group `test`, and pytest's settings, at the end of `pyproject.toml`, turn coverage on for every run.

Read the change of `pyproject.toml`.

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented out.
No test used them, so the project does not keep them.

The move changes these files:

- `pyproject.toml`: 6 lines added; pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: 102 lines added; pytest-cov and coverage.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/bed3c6029878c71bef05322712c388dfb8c058ef/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
  - look at: `addopts = "--cov=wikiapp --cov-report=term-missing"`

The change of `pyproject.toml`:

```diff
@@ -18,6 +18,7 @@ wikiapp = "wikiapp.console:main"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
 dev = [{ include-group = "test" }]
@@ -25,3 +26,8 @@ dev = [{ include-group = "test" }]
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
+
+[tool.pytest.ini_options]
+testpaths = ["tests"]
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
+addopts = "--cov=wikiapp --cov-report=term-missing"
```

```bash
just test
```

The table under the tests lists each file of `src/wikiapp`, its statements, and the lines that no test ran.
One line of `console.py` is missing. It is the call to `main` at the end, which runs only when you run the file
as a script.

## step-03 A library and an app

[The code at step-03](https://github.com/rahuldave/smallwikiapp/tree/step-03)

```bash
just setup
```

The code that asks Wikipedia moves into a module of its own, `wikipedia.py`. The module then gets a language
and an error of its own. The command, in `console.py`, uses the module. So wikipedia.py is a library that knows
nothing of the command line, and console.py is the app that uses it.

### step-03.1 random_page moves to wikipedia.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1) shows what the move changes.

Now we move the request into a new module, `src/wikiapp/wikipedia.py`, with the address, the User-Agent and a
function, `random_page`. `random_page` returns the answer from inside the `with` block. The original set `data`
there, and returned it after the block. The result is the same.

Open `src/wikiapp/wikipedia.py`, a new file.

Next we take the constants and the request out of `src/wikiapp/console.py`, and `main` calls `random_page`.

Find `data = random_page()` in the change of `src/wikiapp/console.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 10 lines added; a new file with the address, the User-Agent, and `random_page`.
- `src/wikiapp/console.py`: 6 lines added, 10 removed; `main` calls `random_page`.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/wikipedia.py): the code that talks to Wikipedia.
  - look at: `def random_page():`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): only the command stays.
  - look at: `data = random_page()`

The change of `src/wikiapp/console.py`:

```diff
@@ -1,22 +1,18 @@
 import click
 from wikiapp import __version__
-import requests
 import textwrap
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
-USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+from wikiapp.wikipedia import random_page
 
 @click.command()
 @click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        data = response.json()
-        title = data["title"]
-        extract = data["extract"]
-        click.secho(title, fg="green")
-        click.echo(textwrap.fill(extract))
+    data = random_page()
+    title = data["title"]
+    extract = data["extract"]
+    click.secho(title, fg="green")
+    click.echo(textwrap.fill(extract))
 
 if __name__=="__main__":
     main()
```

```bash
just test
```

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. wikipedia.py calls the function through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e) shows what the move changes.

Now we share the mock with every test file. pytest reads `tests/conftest.py` before the tests, and every test file
can use a fixture in it. The tests of wikipedia.py, in the next move, need the mock too. So the fixture
`mock_requests_get` moves from `tests/test_console.py` to a new file, `tests/conftest.py`.

Open `tests/conftest.py`, a new file. Read the change of `tests/test_console.py`.

The move changes these files:

- `tests/conftest.py`: 10 lines added; a new file with the mock.
- `tests/test_console.py`: 9 lines removed; the mock is gone.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone, but the tests still name it.

The change of `tests/test_console.py`:

```diff
@@ -5,15 +5,6 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
-@pytest.fixture
-def mock_requests_get(mocker):
-    mock = mocker.patch("requests.get")
-    mock.return_value.__enter__.return_value.json.return_value = {
-        "title": "Lorem Ipsum",
-        "extract": "Lorem ipsum dolor sit amet",
-    }
-    return mock
-
 from wikiapp import console
 
 def test_main_prints_title(runner, mock_requests_get):
```

```bash
just test
```

The result is `5 passed`. pytest finds the fixture in conftest.py.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4) shows what the move changes.

Now we let `random_page` ask the Wikipedia of a language. Each language has its own Wikipedia, at
LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, the address has a placeholder for the language.
`random_page` fills it, with English as the default.

Read the change of `src/wikiapp/wikipedia.py`.

Then we write the first test of the library, in `tests/test_wikipedia.py`, which asks for a page in Spanish. It
checks that the address of the request contains `es.wikipedia.org`.

Open `tests/test_wikipedia.py`, a new file.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 3 removed; `random_page` takes a language.
- `tests/test_wikipedia.py`: 6 lines added; a new file with a test that the language chooses the Wikipedia.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the placeholder, and the code that fills it.
  - look at: `def random_page(language="en"):`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/tests/test_wikipedia.py): the test uses the mock from conftest.py.
  - look at: `assert "es.wikipedia.org" in args[0]`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,10 +1,10 @@
 import requests
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
-def random_page():
+def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
+    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         return response.json()
```

```bash
just test
```

The result is `6 passed`.

### step-03.4 wikiapp --language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f) shows what the move changes.

Now we let the user choose the language of the page. In `src/wikiapp/console.py`, a new option `--language`, or
`-l`, comes between `@click.command()` and `@click.version_option`. `main` takes a parameter `language`, and passes
it on to `random_page`.

Read the change of `src/wikiapp/console.py`.

click gives the value of the option to the parameter with the same name.

The move changes one file:

- `src/wikiapp/console.py`: 10 lines added, 2 removed; the option `--language`, or `-l`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3bd5616ab15d6b2b526784e8b3b014bceef2548f/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the option, which `main` gives to `random_page`.
  - look at: `data = random_page(language=language)`

The change of `src/wikiapp/console.py`:

```diff
@@ -5,10 +5,18 @@ import textwrap
 from wikiapp.wikipedia import random_page
 
 @click.command()
+@click.option(
+    "--language",
+    "-l",
+    default="en",
+    help="Gets random page from Wikipedia in given language",
+    metavar="LANG",
+    show_default=True,
+)
 @click.version_option(version=__version__)
-def main() -> None:
+def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page()
+    data = random_page(language=language)
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

The first command prints a French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea) shows what the move changes.

Now we make `random_page` raise an exception of the library when a request fails. If a request fails for any
reason, requests raises a `RequestException`. Code that uses the library should not need to know the exceptions of
requests. So the library raises an exception of its own. In `src/wikiapp/wikipedia.py`, the class `WikipediaError`
comes above `random_page`. The request is now in a `try` block, and a `RequestException` becomes a
`WikipediaError`.

Read the change of `src/wikiapp/wikipedia.py`.

`from error` keeps the original exception, so a traceback shows both exceptions.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 9 lines added, 3 removed; the class `WikipediaError`, which `random_page` raises.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/56214d31141adcc3dab1ecdd7545b94b03c7f0ea/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the exception, and the line that raises it.
  - look at: `raise WikipediaError(str(error)) from error`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -3,8 +3,14 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        return response.json()
+    try:
+        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+            response.raise_for_status()
+            return response.json()
+    except requests.RequestException as error:
+        raise WikipediaError(str(error)) from error
```

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback, and the last line is the `WikipediaError`. No code catches the error yet.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7) shows what the move changes.

Now we make `main` print a `WikipediaError` as a message. `src/wikiapp/console.py` imports the error with
`random_page`. `main` catches it, and raises the exception of click in its place. click prints that exception as a
message.

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and
requests, and console.py knows click.

Read the change of `src/wikiapp/console.py`.

Then we add a test, `test_main_prints_message_on_request_error`, which makes the mock raise a `RequestException`.
It checks that the output contains `Error`. `tests/test_console.py` now imports `requests`.

Find `mock_requests_get.side_effect = requests.RequestException` in the change of `tests/test_console.py`.

The move changes these files:

- `src/wikiapp/console.py`: 5 lines added, 2 removed; `main` catches WikipediaError.
- `tests/test_console.py`: 6 lines added; a test of the message.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
  - look at: `assert "Error" in result.output`

The change of `src/wikiapp/console.py`:

```diff
@@ -2,7 +2,7 @@ import click
 from wikiapp import __version__
 import textwrap
 
-from wikiapp.wikipedia import random_page
+from wikiapp.wikipedia import WikipediaError, random_page
 
 @click.command()
 @click.option(
@@ -16,7 +16,10 @@ from wikiapp.wikipedia import random_page
 @click.version_option(version=__version__)
 def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page(language=language)
+    try:
+        data = random_page(language=language)
+    except WikipediaError as error:
+        raise click.ClickException(str(error)) from error
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

The change of `tests/test_console.py`:

```diff
@@ -1,5 +1,6 @@
 import click.testing
 import pytest
+import requests
 
 @pytest.fixture
 def runner():
@@ -24,6 +25,11 @@ def test_main_fails_on_request_error(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+def test_main_prints_message_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = requests.RequestException
+    result = runner.invoke(console.main)
+    assert "Error" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
uv run wikiapp --language xx; echo "exit code $?"
just test
```

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

## step-04 Format, lint, a hook

[The code at step-04](https://github.com/rahuldave/smallwikiapp/tree/step-04)

```bash
just setup
```

The ten moves of this step add a formatter, and then the changes that it makes. Next, a linter finds five
problems, and the next three moves fix them. Then a recipe checks the configuration, `uv run` stops updating the
lockfile, and another recipe runs every check. Last, a git hook runs every check before each commit.

A tool comes in one move, and its changes come in the next move. So you see what the tool would change before it
changes anything. The tests still need the network. Also, pre-commit downloads its hooks from GitHub the first
time.

### step-04.1 ruff, and the recipe fmt

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9) shows what the move changes.

Now we add ruff, a formatter and a linter in one program, to a third dependency group, `lint`, which `dev`
includes.

Find `dev = [{ include-group = "test" }, { include-group = "lint" }]` in the change of `pyproject.toml`.

Next we give ruff its settings, at the end of `pyproject.toml`. They set lines of up to 100 characters, and
write out the defaults of the formatter.

Find `line-length = 100` in the change of `pyproject.toml`.

Then we add a recipe `fmt`, which runs the formatter. The words after `just fmt` go to `ruff format`.

Find `fmt *args:` in the change of `justfile`.

The move changes these files:

- `pyproject.toml`: 15 lines added, 1 removed; the group `lint`, and ruff's settings.
- `justfile`: 6 lines added; the recipe `fmt`.
- `uv.lock`: 31 lines added; ruff.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group and the settings.
  - look at: `line-length = 100`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `fmt *args:`

The change of `pyproject.toml`:

```diff
@@ -21,7 +21,10 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
-dev = [{ include-group = "test" }]
+dev = [{ include-group = "test" }, { include-group = "lint" }]
+lint = [
+    "ruff>=0.17.0",
+]
 
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
@@ -31,3 +34,14 @@ build-backend = "uv_build"
 testpaths = ["tests"]
 # Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
 addopts = "--cov=wikiapp --cov-report=term-missing"
+
+[tool.ruff]
+# The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
+# better at 100.
+line-length = 100
+
+[tool.ruff.format]
+# The formatter has no style to argue about. These are ruff's defaults, written out so they are visible.
+quote-style = "double"            # "text", not 'text'
+indent-style = "space"            # four spaces, never tabs
+skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
```

The change of `justfile`:

```diff
@@ -25,3 +25,9 @@ setup *args:
 [no-exit-message]
 test *args:
     {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
+
+# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
+[group('quality')]
+[no-exit-message]
+fmt *args:
+    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing. It lists the files that it would change, and fails. It prints `6 files would be
reformatted, 1 file already formatted`. The seventh file is the README. The recipe runs the same command, and
passes on the words after `just fmt`.

### step-04.2 The code, formatted

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986) shows what the move changes.

Now we run the formatter, which rewrites six files. It adds blank lines, puts spaces around `==`, and splits the
lines longer than 100 characters.

Find `if __name__ == "__main__":` in the change of `src/wikiapp/console.py`. Then read the changes of
`src/wikiapp/wikipedia.py` and `tests/test_console.py`.

The move changes these files:

- `src/wikiapp/__init__.py`: 1 line added; a blank line after the import.
- `src/wikiapp/console.py`: 3 lines added, 1 removed; two blank lines before the command and before `if __name__`, and spaces around `==`.
- `src/wikiapp/wikipedia.py`: 5 lines added, 1 removed; two blank lines around the class, and the request, longer than 100 characters, split.
- `tests/conftest.py`: 1 line added; two blank lines before the fixture.
- `tests/test_console.py`: 11 lines added, 1 removed; two blank lines around each function, and the line longer than 100 characters split.
- `tests/test_wikipedia.py`: 1 line added; two blank lines before the test.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/ca8685e532e9d372857667484e1c94c91ac9e986/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): blank lines, and spaces around `==`.
  - look at: `if __name__ == "__main__":`
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/ca8685e532e9d372857667484e1c94c91ac9e986/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the long line of the request, split into three.
  - look at: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/ca8685e532e9d372857667484e1c94c91ac9e986/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): blank lines, and the long address split.
  - look at: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`

The change of `src/wikiapp/console.py`:

```diff
@@ -4,6 +4,7 @@ import textwrap
 
 from wikiapp.wikipedia import WikipediaError, random_page
 
+
 @click.command()
 @click.option(
     "--language",
@@ -25,5 +26,6 @@ def main(language) -> None:
     click.secho(title, fg="green")
     click.echo(textwrap.fill(extract))
 
-if __name__=="__main__":
+
+if __name__ == "__main__":
     main()
```

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -3,13 +3,17 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+
 class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
-        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+        ) as response:
             response.raise_for_status()
             return response.json()
     except requests.RequestException as error:
```

The change of `tests/test_console.py`:

```diff
@@ -2,34 +2,44 @@ import click.testing
 import pytest
 import requests
 
+
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
+
 from wikiapp import console
 
+
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+
 def test_main_invokes_requests_get(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.called
 
+
 def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
-    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+    assert mock_requests_get.call_args[0] == (
+        "https://en.wikipedia.org/api/rest_v1/page/random/summary",
+    )
+
 
 def test_main_fails_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+
 def test_main_prints_message_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just fmt --check
just test
```

The check prints `7 files already formatted`, and the tests pass as before. The formatter changes how the code
looks, and never what it does. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-04.3 The linter's rules, and the recipe lint

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e) shows what the move changes.

Now we choose the linter's rules, in a table at the end of `pyproject.toml`. The linter checks the code against
rules, and the table chooses the families of rules, one family on each line. The tests may use `assert`. The rest
of the code may not use it, because Python skips every `assert` when it runs with `-O`.

Find `select = [` and `"tests/**" = ["S101"]` in the change of `pyproject.toml`.

Next we add a recipe `lint`, which runs the linter. The words after `just lint` go to `ruff check`.

Find `lint *args:` in the change of `justfile`.

The move changes these files:

- `pyproject.toml`: 18 lines added; the rules.
- `justfile`: 6 lines added; the recipe `lint`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): a family of rules on each line.
  - look at: `"tests/**" = ["S101"]`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `lint *args:`

The change of `pyproject.toml`:

```diff
@@ -45,3 +45,21 @@ line-length = 100
 quote-style = "double"            # "text", not 'text'
 indent-style = "space"            # four spaces, never tabs
 skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
+
+[tool.ruff.lint]
+# What the linter checks: a family of rules on each line, and why it is on
+select = [
+    "E",   # pycodestyle errors: the basics, from indentation to line length
+    "W",   # pycodestyle warnings: stray whitespace and the like
+    "F",   # pyflakes: names that are unused, undefined or redefined
+    "I",   # isort: imports in one order, standard library first
+    "B",   # bugbear: constructs that are likely bugs, such as a mutable default argument
+    "UP",  # pyupgrade: older syntax that this Python has a newer form for
+    "SIM", # simplify: code that can be said in fewer words
+    "S",   # bandit: security, from `assert` in production code to a request with no timeout
+    "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+]
+
+[tool.ruff.lint.per-file-ignores]
+# A test is written with assert
+"tests/**" = ["S101"]
```

The change of `justfile`:

```diff
@@ -31,3 +31,9 @@ test *args:
 [no-exit-message]
 fmt *args:
     {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
+
+# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
+[group('quality')]
+[no-exit-message]
+lint *args:
+    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

```bash
uv run ruff check --statistics
just --show lint
just lint --statistics
```

The linter finds five problems, each with its code:

- `I001`: the imports of console.py are out of order.
- `E402`: an import in test_console.py comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

`just lint` shows each problem with its lines. `uv run ruff rule S113` explains a code.

### step-04.4 The linter sorts the imports

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf) shows what the move changes.

Now we let ruff fix the one problem of the five that it can fix itself. `just lint --fix` sorts the imports of
`console.py`.

Find `from wikiapp import __version__` in the change of `src/wikiapp/console.py`.

The move changes one file:

- `src/wikiapp/console.py`: 3 lines added, 2 removed; the imports in three blocks, which are the standard library, the packages
  installed, and then wikiapp's own.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the imports, sorted.
  - look at: `from wikiapp import __version__`

The change of `src/wikiapp/console.py`:

```diff
@@ -1,7 +1,8 @@
-import click
-from wikiapp import __version__
 import textwrap
 
+import click
+
+from wikiapp import __version__
 from wikiapp.wikipedia import WikipediaError, random_page
 
 
```

```bash
just lint --statistics
```

`just lint --fix` reported `Found 5 errors (1 fixed, 4 remaining)` and failed. Four problems are left, and a
person must fix them.

### step-04.5 The tests' imports at the top, and no unused variables

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46) shows what the move changes.

Now we move `from wikiapp import console` up in `tests/test_console.py`, under `import requests`. A reader looks
for imports there. wikiapp's own imports are a block of their own, after the installed packages, as `--fix` made
them in console.py.

Find `from wikiapp import console` in the change of `tests/test_console.py`.

Next we drop `result =` in `test_main_invokes_requests_get` and `test_main_uses_correct_url`, since no line reads
the result. The two tests check the mock, not the result.

Find `runner.invoke(console.main)` twice in the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 4 lines added, 5 removed; the import at the top, and two assignments gone.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/3ba5d239ff4f171c58d4249a33caafc510883b46/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the import moves, and two lines lose `result =`.
  - look at: `from wikiapp import console`

The change of `tests/test_console.py`:

```diff
@@ -2,27 +2,26 @@ import click.testing
 import pytest
 import requests
 
+from wikiapp import console
+
 
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
 
-from wikiapp import console
-
-
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
 def test_main_invokes_requests_get(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.called
 
 
 def test_main_uses_correct_url(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
```

```bash
just lint --statistics
just fmt --check
```

One problem is left, `S113`. The format is unchanged, and the check prints `7 files already formatted`.

### step-04.6 A timeout

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c) shows what the move changes.

Now we give the request a timeout, because without one, requests waits as long as the server keeps the
connection open. So the command can wait for ever. The request in `src/wikiapp/wikipedia.py` now has `timeout=10`.

Find `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10` in the change of
`src/wikiapp/wikipedia.py`.

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 1 line added, 1 removed; the timeout.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/80c33d4cfaf4b157cd44482712e520c77378cf9c/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): one more argument.
  - look at: `timeout=10`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -12,7 +12,7 @@ def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
-            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
             return response.json()
```

```bash
just lint
```

`All checks passed!`

### step-04.7 The recipe lint-config

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a) shows what the move changes.

Now we add validate-pyproject to the group `lint`, and a recipe `lint-config` that checks the configuration.
The recipe runs three commands. validate-pyproject checks `pyproject.toml` against the standard for it,
`uv lock --check` checks the lockfile, and `just --fmt --check --unstable` checks the `justfile`.

Find `"validate-pyproject>=0.26",` in the change of `pyproject.toml`. Then find `lint-config *args:` in the
change of `justfile`.

The move changes these files:

- `justfile`: 11 lines added; the recipe `lint-config`.
- `pyproject.toml`: 1 line added; validate-pyproject in the group `lint`.
- `uv.lock`: 28 lines added, 1 removed; the exact version of validate-pyproject, and of what it needs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its three checks.
  - look at: `uv run validate-pyproject pyproject.toml`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one package more in `lint`.
  - look at: `"validate-pyproject>=0.26",`

The change of `justfile`:

```diff
@@ -37,3 +37,14 @@ fmt *args:
 [no-exit-message]
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
+
+# Check the configuration: pyproject.toml, the lockfile, and this justfile
+[group('quality')]
+[no-exit-message]
+lint-config *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help lint-config; exit 0; fi
+    uv run validate-pyproject pyproject.toml
+    uv lock --check
+    just --fmt --check --unstable
```

The change of `pyproject.toml`:

```diff
@@ -24,6 +24,7 @@ test = [
 dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
     "ruff>=0.17.0",
+    "validate-pyproject>=0.26",
 ]
 
 [build-system]
```

```bash
uv run validate-pyproject pyproject.toml
uv lock --check
just --fmt --check --unstable
just --show lint-config
just lint-config
```

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`.

### step-04.8 A locked lockfile

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb) shows what the move changes.

Now we export the variable `UV_LOCKED` from the `justfile`, under `set positional-arguments`. With it, every `uv
run` of a recipe refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

Find `export UV_LOCKED := "1"` in the change of `justfile`.

The move changes one file:

- `justfile`: 2 lines added; the variable `UV_LOCKED`, exported to every recipe.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/a45828b7972f3de77bd6a8d7a00a6b55833832cb/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): one line.
  - look at: `export UV_LOCKED := "1"`

The change of `justfile`:

```diff
@@ -3,6 +3,8 @@
 # Each word after a recipe's name reaches its commands whole, as "$1", "$2" and so on; "$@" is all of them
 set positional-arguments
 
+export UV_LOCKED := "1"
+
 [private]
 default:
     @just --list --unsorted
```

```bash
just --evaluate UV_LOCKED
```

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

### step-04.9 The recipe check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows what the move changes.

Now we add a recipe `check`, which runs every check in order. It stops at the first check that fails. The order is
the format, the linter, the tests with a floor on the coverage, and the configuration.

Find `just test -q --cov-fail-under=90` in the change of `justfile`.

The move changes one file:

- `justfile`: 12 lines added; the recipe `check`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/06ea9e2af2238f070b1e33f16aeb70002e25e44d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its four checks.
  - look at: `just test -q --cov-fail-under=90`

The change of `justfile`:

```diff
@@ -50,3 +50,15 @@ lint-config *args:
     uv run validate-pyproject pyproject.toml
     uv lock --check
     just --fmt --check --unstable
+
+# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+[group('quality')]
+[no-exit-message]
+check *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help check; exit 0; fi
+    just fmt --check
+    just lint
+    just test -q --cov-fail-under=90
+    just lint-config
```

```bash
just --show check
just check
```

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

### step-04.10 A git hook

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db) shows what the move changes.

Now we add pre-commit, which installs a git hook, to the group `lint`. A git hook is a program that git runs
before every commit. If the program fails, git refuses the commit.

Find `"pre-commit>=4.6.2",` in the change of `pyproject.toml`.

Next we make `.pre-commit-config.yaml`, a new file that names the hooks. Three come from pre-commit's collection.
They check for valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the
hook and the terminal run the same thing.

Open `.pre-commit-config.yaml`, a new file. Find `entry: just check` in it.

Then we add a recipe `hook`, after `setup` in the `justfile`, which installs the hook. It is a recipe of its own,
run once in each clone, because `just setup` runs at every step and never touches git.

Find `hook *args:` in the change of `justfile`.

The move changes these files:

- `.pre-commit-config.yaml`: 20 lines added; a new file, with the hooks.
- `justfile`: 5 lines added; the recipe `hook`, which installs the hook.
- `pyproject.toml`: 1 line added; pre-commit in the group `lint`.
- `uv.lock`: 138 lines added; the exact version of pre-commit, and of what it needs.

Files to read:
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe `hook`.
  - look at: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
  - look at: `"pre-commit>=4.6.2",`

The change of `justfile`:

```diff
@@ -22,6 +22,11 @@ help *verb:
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
 
+# Install the git hook: just check before every commit. Once per clone; just setup never touches git
+[group('setup')]
+hook *args:
+    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
+
 # Run the tests. Extra arguments go to pytest: just test -k title
 [group('quality')]
 [no-exit-message]
```

The change of `pyproject.toml`:

```diff
@@ -23,6 +23,7 @@ test = [
 ]
 dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
+    "pre-commit>=4.6.2",
     "ruff>=0.17.0",
     "validate-pyproject>=0.26",
 ]
```

```bash
uv run pre-commit install
just --show hook
just hook
uv run pre-commit run --files .pre-commit-config.yaml
```

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, and no step or move changes that folder. The hook stays installed for the
rest of the tutorial.

`pre-commit run` now runs every hook on the file named, as git will before a commit. The first time on a machine, it
prints `[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, pre-commit would check every file that git tracks. It would skip a new file until git tracks
it.

## step-05 Types

[The code at step-05](https://github.com/rahuldave/smallwikiapp/tree/step-05)

```bash
just setup
```

The six moves of this step add a type checker, and fix the one problem that it finds. Then a lint rule asks for
a type on every parameter and return. The last moves add the types, and put the type checker in `just check`.

### step-05.1 ty, and the recipe types

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e) shows what the move changes.

Now we add ty, a type checker, to the group `lint`. ty reads the code without running it. It finds code whose
types cannot fit, for example a call whose arguments cannot have the types that the function asks for.

Find `"ty>=0.0.86",` in the change of `pyproject.toml`.

Next we add a recipe `types`, which runs ty, after the recipe `lint` in the `justfile`.

Find `types *args:` in the change of `justfile`.

The move changes these files:

- `justfile`: 6 lines added; the recipe `types`.
- `pyproject.toml`: 1 line added; ty in the group `lint`.
- `uv.lock`: 29 lines added; the exact version of ty.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.86",`

The change of `justfile`:

```diff
@@ -45,6 +45,12 @@ fmt *args:
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
 
+# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
+[group('quality')]
+[no-exit-message]
+types *args:
+    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}
+
 # Check the configuration: pyproject.toml, the lockfile, and this justfile
 [group('quality')]
 [no-exit-message]
```

The change of `pyproject.toml`:

```diff
@@ -25,6 +25,7 @@ dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
     "pre-commit>=4.6.2",
     "ruff>=0.17.0",
+    "ty>=0.0.86",
     "validate-pyproject>=0.26",
 ]
 
```

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2c744eaef504d1adcc7fba0938360d140ef49978) shows what the move changes.

Now we ask for the version of `wikiapp` by name, in the last line of `src/wikiapp/__init__.py`.
`pyproject.toml` gives the name of the installed package, `wikiapp`. The name is a string that is never None.

Find `__version__ = importlib.metadata.version("wikiapp")` in the change of `src/wikiapp/__init__.py`.

The move changes one file:

- `src/wikiapp/__init__.py`: 1 line added, 1 removed; the name, written out.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/2c744eaef504d1adcc7fba0938360d140ef49978/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2c744eaef504d1adcc7fba0938360d140ef49978#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a string that is never None.
  - look at: `__version__ = importlib.metadata.version("wikiapp")`

The change of `src/wikiapp/__init__.py`:

```diff
@@ -1,3 +1,3 @@
 import importlib.metadata
 
-__version__ = importlib.metadata.version(__name__ or __package__)
+__version__ = importlib.metadata.version("wikiapp")
```

```bash
just types
```

`All checks passed!`

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/50af6273ec0db467642d539935422d0f4fc50991) shows what the move changes.

Now we turn on ruff's `ANN` rules, with one line in the list `select` in `pyproject.toml`, after `"N"`. ty, the
type checker that `just types` runs, checks the types that the code states. The `ANN` rules make sure that the code
states a type for every parameter and return.

Find `"ANN", # annotations: every parameter and every return value has a type` in the change of
`pyproject.toml`.

The move changes one file:

- `pyproject.toml`: 1 line added; the rules `ANN`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/50af6273ec0db467642d539935422d0f4fc50991/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/50af6273ec0db467642d539935422d0f4fc50991#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"ANN", # annotations: every parameter and every return value has a type`

The change of `pyproject.toml`:

```diff
@@ -61,6 +61,7 @@ select = [
     "SIM", # simplify: code that can be said in fewer words
     "S",   # bandit: security, from `assert` in production code to a request with no timeout
     "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+    "ANN", # annotations: every parameter and every return value has a type
 ]
 
 [tool.ruff.lint.per-file-ignores]
```

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). `just check` fails at this move and at the next move, and passes again at step-05.5. So the
git hook would refuse a commit of this move or of the next.

### step-05.4 Types in the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b) shows what the move changes.

Now we add the types to the code, in `src/wikiapp/wikipedia.py` and `src/wikiapp/console.py`.

In `src/wikiapp/wikipedia.py`, `random_page` takes a string. It returns the JSON that Wikipedia sends, which is
a dictionary from strings to values of any kind. `Any` says that ty cannot check the values. The file imports
`Any` at the top, above `import requests`. The standard library is a block of its own.

In `src/wikiapp/console.py`, `main` takes the language as a string. Its return type, None, was already there.

Find `def random_page(language: str = "en") -> dict[str, Any]:` in the change of `src/wikiapp/wikipedia.py`.
Then find `def main(language: str) -> None:` in the change of `src/wikiapp/console.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 1 removed; the types of `random_page`.
- `src/wikiapp/console.py`: 1 line added, 1 removed; the type of `main`'s parameter.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/48523b8748a8bd60f80b73e1b2b2322eb616325b/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the parameter and the return.
  - look at: `def random_page(language: str = "en") -> dict[str, Any]:`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/48523b8748a8bd60f80b73e1b2b2322eb616325b/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the parameter.
  - look at: `def main(language: str) -> None:`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+from typing import Any
+
 import requests
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
@@ -8,7 +10,7 @@ class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
 
-def random_page(language="en"):
+def random_page(language: str = "en") -> dict[str, Any]:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
```

The change of `src/wikiapp/console.py`:

```diff
@@ -16,7 +16,7 @@ from wikiapp.wikipedia import WikipediaError, random_page
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language) -> None:
+def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
         data = random_page(language=language)
```

```bash
just lint --statistics
```

The 22 problems that are left are all in the tests. They are 13 parameters and 9 returns.

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff) shows what the move changes.

Now we add the types to the tests, first to the fixture in `tests/conftest.py`. Since step-05.3, ruff's `ANN`
rules ask for a type on every parameter and return. The code has its types, and `just lint` finds 22 missing in
the tests.

The return type of a fixture is the type of what a test receives. The mock of `requests.get` is a `Mock`.
`mocker` is pytest-mock's `MockerFixture`, the name that replaced the original wikiapp's `MockFixture`.
`tests/conftest.py` now imports `Mock` and `MockerFixture`, and its fixture states both types.

Find `def mock_requests_get(mocker: MockerFixture) -> Mock:` in the change of `tests/conftest.py`.

Next we add the types to `tests/test_console.py` and `tests/test_wikipedia.py`. A test returns None.
`tests/test_console.py` imports `Mock` and `CliRunner` by name. The fixture `runner` returns `CliRunner()`, so its
return type is `CliRunner`. Every function has its types. `tests/test_wikipedia.py` imports `Mock` at the top, and
its test has its types.

Read the change of `tests/test_console.py`. Then find
`def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.

The move changes these files:

- `tests/conftest.py`: 4 lines added, 1 removed; the types of the fixture.
- `tests/test_console.py`: 11 lines added, 9 removed; the types of the fixture and of every test.
- `tests/test_wikipedia.py`: 3 lines added, 1 removed; the types of the test.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

The change of `tests/conftest.py`:

```diff
@@ -1,8 +1,11 @@
+from unittest.mock import Mock
+
 import pytest
+from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker):
+def mock_requests_get(mocker: MockerFixture) -> Mock:
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

The change of `tests/test_console.py`:

```diff
@@ -1,44 +1,46 @@
-import click.testing
+from unittest.mock import Mock
+
 import pytest
 import requests
+from click.testing import CliRunner
 
 from wikiapp import console
 
 
 @pytest.fixture
-def runner():
-    return click.testing.CliRunner()
+def runner() -> CliRunner:
+    return CliRunner()
 
 
-def test_main_prints_title(runner, mock_requests_get):
+def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner, mock_requests_get):
+def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner, mock_requests_get):
+def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner, mock_requests_get):
+def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner, mock_requests_get):
+def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner):
+def test_main_succeeds(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,7 +1,9 @@
+from unittest.mock import Mock
+
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get):
+def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
```

```bash
just lint
just types
```

Both commands pass.

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d) shows what the move changes.

Now we put the type checker in the recipe `check` of the `justfile`, after `just lint`. The comment of `check`
names the types too.

Find `just types` in the change of `justfile`, and the comment of `check` above it.

The move changes one file:

- `justfile`: 2 lines added, 1 removed; `check` runs the type checker.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/41990df7638f0964c66bf4e4433ffc4f5b6a026d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
  - look at: `just types`

The change of `justfile`:

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -71,5 +71,6 @@ check *args:
     if [ "$*" = help ]; then just help check; exit 0; fi
     just fmt --check
     just lint
+    just types
     just test -q --cov-fail-under=90
     just lint-config
```

```bash
just check
```

Every check passes, the type check among them. The coverage is 96.88%.

## step-06 End to end, and CI

[The code at step-06](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

The moves of this step do three things. The tests that ask the real Wikipedia run only when you ask for them.
The project accepts every Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only on request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5) shows what the move changes.

Now we mark the test that asks the real Wikipedia, so that it runs only on request.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, it now has the marker `e2e`, which means end to end. Its new
name says so, `test_main_succeeds_in_production`. `pyproject.toml` declares the marker in `markers`. The option
`-m 'not e2e'` in `addopts` leaves the e2e tests out of every run that does not ask for them.

Find `@pytest.mark.e2e` in the change of `tests/test_console.py`. Then read the change of `pyproject.toml`.

The move changes these files:

- `tests/test_console.py`: 2 lines added, 1 removed; the marker, and the name.
- `pyproject.toml`: 5 lines added, 2 removed; the marker, declared, and the e2e tests left out of a plain run.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the option `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

The change of `tests/test_console.py`:

```diff
@@ -41,6 +41,7 @@ def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_g
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner: CliRunner) -> None:
+@pytest.mark.e2e
+def test_main_succeeds_in_production(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `pyproject.toml`:

```diff
@@ -35,8 +35,11 @@ build-backend = "uv_build"
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
-addopts = "--cov=wikiapp --cov-report=term-missing"
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
+# just test -m e2e
+addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
 # The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
```

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d) shows what the move changes.

Now we add an end-to-end test of the library, `random_page`. The mocks return a dictionary with a title and an
extract. A second e2e test, from the original wikiapp, checks that the real Wikipedia still returns the same keys.
It is `test_random_page_returns_dictionary_in_production`, at the end of `tests/test_wikipedia.py`. The file now
imports pytest, in a block of its own.

Find `def test_random_page_returns_dictionary_in_production() -> None:` in the change of `tests/test_wikipedia.py`.

The move changes one file:

- `tests/test_wikipedia.py`: 9 lines added; an e2e test.

Files to read:
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/41e5681a18bc9975f383d1520b8781c4e836e90d/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,5 +1,7 @@
 from unittest.mock import Mock
 
+import pytest
+
 from wikiapp import wikipedia
 
 
@@ -7,3 +9,10 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
+
+
+@pytest.mark.e2e
+def test_random_page_returns_dictionary_in_production() -> None:
+    page = wikipedia.random_page()
+    assert "title" in page
+    assert "extract" in page
```

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761) shows what the move changes.

Now we let the project accept every Python from 3.11 on. `uv init` wrote `requires-python = ">=3.13"`, because the
command asked for Python 3.13. Nothing here needs more than 3.11. Python 3.10 reached its end of life on 1 October
2026, so 3.11 is now the oldest Python that still gets security fixes. The line in `pyproject.toml` now says 3.11,
and uv solves the lockfile again.

Find `requires-python = ">=3.11"` in the change of `pyproject.toml`.

The project still runs on 3.13, from `.python-version`.

The move changes these files:

- `pyproject.toml`: 1 line added, 1 removed; the oldest Python that the project accepts.
- `uv.lock`: 160 lines added, 2 removed; solved for every Python from 3.11 on.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/15ba9fa843e3f055dac9c8f1a844b7382858b761/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

The change of `pyproject.toml`:

```diff
@@ -6,7 +6,7 @@ readme = "README.md"
 license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
-requires-python = ">=3.13"
+requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
     "requests>=2.34.2",
```

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d3f84ea883f0e41f64fb397f436c89e372c83bff) shows what the move changes.

Now we add a GitHub Actions workflow, which runs the tests on the machines of GitHub. A GitHub Actions workflow is
a file in `.github/workflows/`. GitHub runs the jobs of the workflow on every push to main and on every pull
request. The workflow `.github/workflows/test.yaml` has two jobs. The job `tests` runs the tests on three systems
and four Pythons. The job `check` runs `just check` once.

Open `.github/workflows/test.yaml`, a new file. Find `python: ["3.11", "3.12", "3.13", "3.14"]` in it.

The original wikiapp used pixi for the same work, with one environment for each Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

The move changes one file:

- `.github/workflows/test.yaml`: 37 lines added; a new file with two jobs. GitHub runs one of the jobs twelve times.

Files to read:
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/d3f84ea883f0e41f64fb397f436c89e372c83bff/.github/workflows/test.yaml): the matrix of systems and Pythons.
  - look at: `python: ["3.11", "3.12", "3.13", "3.14"]`

```bash
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs.

## step-07 A page with a shape

[The code at step-07](https://github.com/rahuldave/smallwikiapp/tree/step-07)

```bash
just setup
```

The moves of this step give a page a shape. A pydantic model says what a page is, and `random_page` returns
one. An answer that is not a page becomes an error like any other. The last move checks that the language is a
language code.

### step-07.1 The model Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8) shows what the move changes.

Now we add pydantic, a library that checks data against a model. The command uses two of the many keys that
Wikipedia sends. Until now, the code expects these keys to be there, with strings as values, but nothing checks it.
A pydantic model states the two keys and their types in code. pydantic is a dependency of the package, as click and
requests are.

Find `"pydantic>=2.14.0",` in the change of `pyproject.toml`.

Next we write the model `Page` in `src/wikiapp/wikipedia.py`, after `WikipediaError`. It has a title and an
extract, both strings. The file imports `BaseModel` under `import requests`.

Find `from pydantic import BaseModel` and `class Page(BaseModel):` in the change of `src/wikiapp/wikipedia.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 8 lines added; the class `Page`.
- `pyproject.toml`: 1 line added; pydantic, a dependency of the package, as click and requests are.
- `uv.lock`: 180 lines added; the exact version of pydantic, and of what it needs.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the model.
  - look at: `class Page(BaseModel):`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pydantic, a dependency of the package.
  - look at: `"pydantic>=2.14.0",`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,6 +1,7 @@
 from typing import Any
 
 import requests
+from pydantic import BaseModel
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
@@ -10,6 +11,13 @@ class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
 
+class Page(BaseModel):
+    """A page of Wikipedia: its title and the summary of its text."""
+
+    title: str
+    extract: str
+
+
 def random_page(language: str = "en") -> dict[str, Any]:
     """Get a random page from Wikipedia."""
     try:
```

The change of `pyproject.toml`:

```diff
@@ -9,6 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
+    "pydantic>=2.14.0",
     "requests>=2.34.2",
 ]
 
```

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails
with a ValidationError, because `extract` is missing.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a) shows what the move changes.

Now we make `random_page`, in `src/wikiapp/wikipedia.py`, return a Page made from the answer. The code no longer
uses `Any`, so its import and the blank line under it are gone.

Find `return Page.model_validate(response.json())` in the change of `src/wikiapp/wikipedia.py`.

Next we make `main`, in `src/wikiapp/console.py`, print the attributes of the page. ty and an editor know the names
of the attributes. A misspelled key of a dictionary shows up only when the program runs.

Find `click.secho(page.title, fg="green")` in the change of `src/wikiapp/console.py`.

Then we rename the e2e test in `tests/test_wikipedia.py` to `test_random_page_returns_page_in_production`, with the
same marker. Its new name says that it checks for a Page. Its two asserts on the keys become one,
`assert isinstance(page, wikipedia.Page)`.

Find `assert isinstance(page, wikipedia.Page)` in the change of `tests/test_wikipedia.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 4 removed; returns a Page.
- `src/wikiapp/console.py`: 3 lines added, 5 removed; prints the attributes of the Page.
- `tests/test_wikipedia.py`: 2 lines added, 3 removed; the e2e test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,5 +1,3 @@
-from typing import Any
-
 import requests
 from pydantic import BaseModel
 
@@ -18,13 +16,13 @@ class Page(BaseModel):
     extract: str
 
 
-def random_page(language: str = "en") -> dict[str, Any]:
+def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
-            return response.json()
+            return Page.model_validate(response.json())
     except requests.RequestException as error:
         raise WikipediaError(str(error)) from error
```

The change of `src/wikiapp/console.py`:

```diff
@@ -19,13 +19,11 @@ from wikiapp.wikipedia import WikipediaError, random_page
 def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
-        data = random_page(language=language)
+        page = random_page(language=language)
     except WikipediaError as error:
         raise click.ClickException(str(error)) from error
-    title = data["title"]
-    extract = data["extract"]
-    click.secho(title, fg="green")
-    click.echo(textwrap.fill(extract))
+    click.secho(page.title, fg="green")
+    click.echo(textwrap.fill(page.extract))
 
 
 if __name__ == "__main__":
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -12,7 +12,6 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 
 @pytest.mark.e2e
-def test_random_page_returns_dictionary_in_production() -> None:
+def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
-    assert "title" in page
-    assert "extract" in page
+    assert isinstance(page, wikipedia.Page)
```

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703) shows what the move changes.

Now we make `random_page` catch an answer that is not a page. When the answer has no title, `model_validate` raises
the ValidationError of pydantic. `random_page` turns it into a WikipediaError, as it does with a failed request. In
`src/wikiapp/wikipedia.py`, the `except` catches ValidationError together with the exception of requests.

Find `except (requests.RequestException, ValidationError) as error:` in the change of `src/wikiapp/wikipedia.py`.

Next we add a test from the original wikiapp, `test_random_page_handles_validation_error`, at the end of
`tests/test_wikipedia.py`. In the test, the mock answers with an empty dictionary.

Find `def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 2 removed; a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: 6 lines added; a test of the ValidationError.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,5 +1,5 @@
 import requests
-from pydantic import BaseModel
+from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
@@ -24,5 +24,5 @@ def random_page(language: str = "en") -> Page:
         ) as response:
             response.raise_for_status()
             return Page.model_validate(response.json())
-    except requests.RequestException as error:
+    except (requests.RequestException, ValidationError) as error:
         raise WikipediaError(str(error)) from error
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -15,3 +15,9 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
+
+
+def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
+    with pytest.raises(wikipedia.WikipediaError):
+        wikipedia.random_page()
```

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc) shows what the move changes.

Now we check, in `random_page`, that the language is a language code before it goes into the address.

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as
`example.com/x?` sends the request to example.com, with the User-Agent. The code of every Wikipedia has only
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. In `src/wikiapp/wikipedia.py`, a pattern
`LANGUAGE` under `API_URL` matches such a code. `random_page` checks the language first, before the `try`. Any
other language raises a WikipediaError.

Find `LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens` and
`if not LANGUAGE.fullmatch(language):` in the change of `src/wikiapp/wikipedia.py`.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 5 lines added; the pattern, and the check.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the code checks a language before it uses it.
  - look at: `if not LANGUAGE.fullmatch(language):`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,7 +1,10 @@
+import re
+
 import requests
 from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 
@@ -18,6 +21,8 @@ class Page(BaseModel):
 
 def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
```

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%. A drop in coverage is
something to know about. The tutorial adds no test to hide it.

## step-08 Docs from the code

[The code at step-08](https://github.com/rahuldave/smallwikiapp/tree/step-08)

```bash
just setup
```

The moves of this step add documentation:

- smalldocs, which makes the reference from the code, and says what has no documentation
- the documentation of the library, of the command and of the tests
- a site
- the tests and the docs in the README's table of folders
- the check of the documentation in `just check`

### step-08.1 smalldocs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371) shows what the move changes.

Now we add smalldocs, which writes the reference from the code and lists what has no documentation. The reference
of a function gives its signature, what it does, and what each parameter is. The signature and the types are in the
code. The docstring says what the function does. A docment says what each parameter is. A docment is the comment
beside a parameter, with one parameter to a line.

The block below shows `random_page` with its docments, as the next move writes them. This move does not change
`random_page`.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

smalldocs reads all three, and writes Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group.

Read the change of `pyproject.toml`.

Next we write `docs/_smalldocs.yml`, the file of settings that smalldocs reads. For now the file has one section,
`api`, the reference. It names the package to document, the address of its source, and the files of the tests to
check.

Open `docs/_smalldocs.yml`, a new file.

Then we add a recipe `docs`, at the end of the `justfile`. `just docs` runs `smalldocs api`, and gives it the words
after `just docs`. `smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

Find `docs *args:` in the change of `justfile`.

The move changes these files:

- `docs/_smalldocs.yml`: 5 lines added; a new file, with the settings of the reference.
- `justfile`: 6 lines added; the recipe `docs`.
- `pyproject.toml`: 4 lines added, 1 removed; the group `docs`, with smalldocs.
- `uv.lock`: 64 lines added; the exact version of smalldocs and of the packages it needs.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/docs/_smalldocs.yml): the package to document, and the tests to check.
  - look at: `packages: [wikiapp]`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

The change of `pyproject.toml`:

```diff
@@ -22,7 +22,10 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
-dev = [{ include-group = "test" }, { include-group = "lint" }]
+dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
+docs = [
+    "smalldocs>=0.1.3",
+]
 lint = [
     "pre-commit>=4.6.2",
     "ruff>=0.17.0",
```

The change of `justfile`:

```diff
@@ -74,3 +74,9 @@ check *args:
     just types
     just test -q --cov-fail-under=90
     just lint-config
+
+# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+[group('docs')]
+[no-exit-message]
+docs *args:
+    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

```bash
uv run smalldocs api module wikipedia --dir docs
uv run smalldocs api check --dir docs
just --show docs
just docs check
```

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. Then it lists every gap, and fails with `1 of 15
functions, methods and classes are typed and documented`. The one is `WikipediaError`, which needs only its
docstring. Above the total, `check` names every gap, and the five modules without a docstring are among them.

### step-08.2 The library documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9) shows what the move changes.

Now we document the library, `src/wikiapp/wikipedia.py`, with four additions:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

Find `) -> Page:  # A page chosen at random` in the change of `src/wikiapp/wikipedia.py`.

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 12 lines added, 4 removed; a docstring for the module, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+"""Wikipedia's REST API: a random page."""
+
 import re
 
 import requests
@@ -15,12 +17,18 @@ class WikipediaError(Exception):
 class Page(BaseModel):
     """A page of Wikipedia: its title and the summary of its text."""
 
-    title: str
-    extract: str
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
 
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
 
-def random_page(language: str = "en") -> Page:
-    """Get a random page from Wikipedia."""
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
     if not LANGUAGE.fullmatch(language):
         raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
```

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0) shows what the move changes.

Now we give `src/wikiapp/__init__.py` and `src/wikiapp/console.py` each a docstring at the top.

Find `"""wikiapp: the title and summary of a random Wikipedia page."""` in the change of
`src/wikiapp/__init__.py`. Then find `"""The wikiapp command."""` in the change of `src/wikiapp/console.py`.

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

Next we document `main` and its option `--language`. `wikiapp --help` prints the docstring of `main` and the help
of each option, so those are documentation too. The help of `--language` now says what a language is. It replaces
the help of the original wikiapp, "Gets random page from Wikipedia in given language". `main` has one parameter to
a line, with its docment, and a docstring that says what `main` prints. A function that returns None needs no
docment for its return.

Find `help="The language of the Wikipedia to ask, as its code: en, fr, es",` in the change of
`src/wikiapp/console.py`. Then find `language: str,  # The language of the Wikipedia to ask, from --language` in
the change of `src/wikiapp/console.py`.

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; a docstring for the module.
- `src/wikiapp/console.py`: 10 lines added, 3 removed; a docstring for the module, the documentation of `main`, and the help of `--language`.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a docstring, which `help(wikiapp)` shows.
  - look at: `"""wikiapp: the title and summary of a random Wikipedia page."""`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

The change of `src/wikiapp/__init__.py`:

```diff
@@ -1,3 +1,5 @@
+"""wikiapp: the title and summary of a random Wikipedia page."""
+
 import importlib.metadata
 
 __version__ = importlib.metadata.version("wikiapp")
```

The change of `src/wikiapp/console.py`:

```diff
@@ -1,3 +1,5 @@
+"""The wikiapp command."""
+
 import textwrap
 
 import click
@@ -11,13 +13,18 @@ from wikiapp.wikipedia import WikipediaError, random_page
     "--language",
     "-l",
     default="en",
-    help="Gets random page from Wikipedia in given language",
+    help="The language of the Wikipedia to ask, as its code: en, fr, es",
     metavar="LANG",
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language: str) -> None:
-    """Print the title and summary of a random Wikipedia page."""
+def main(
+    language: str,  # The language of the Wikipedia to ask, from --language
+) -> None:
+    """Print the title and summary of a random Wikipedia page, in the language asked for.
+
+    The title is in green, and the summary is wrapped to 70 columns.
+    """
     try:
         page = random_page(language=language)
     except WikipediaError as error:
```

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b) shows what the move changes.

Now we document the tests, so that `just docs check` finds no gap. A docment is the comment beside a parameter, or
after the colon of the `def` line for the return. `just docs check`, from step-08.1, counts the functions and
classes that have their types, docments and docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. Each parameter of a test has a docment, one
parameter to a line, and `tests/test_console.py` shows the pattern best.

Read the changes of `tests/conftest.py`, `tests/test_console.py` and `tests/test_wikipedia.py`. Find
`"""The command prints the title of the page."""` in the change of `tests/test_console.py`.

The move changes these files:

- `tests/conftest.py`: 6 lines added, 1 removed; a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: 33 lines added, 7 removed; docstrings for the file, the fixture and each test, and docments for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: 11 lines added, 2 removed; a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

The change of `tests/conftest.py`:

```diff
@@ -1,3 +1,5 @@
+"""What every test file can use: a mock in place of `requests.get`."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker: MockerFixture) -> Mock:
+def mock_requests_get(
+    mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test
+) -> Mock:  # The mock that replaces `requests.get` for the length of one test
+    """Replace `requests.get` with a mock that answers with one page, Lorem Ipsum."""
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

The change of `tests/test_console.py`:

```diff
@@ -1,3 +1,5 @@
+"""Tests of the command, `main`, run in the same process by click's CliRunner."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -8,40 +10,64 @@ from wikiapp import console
 
 
 @pytest.fixture
-def runner() -> CliRunner:
+def runner() -> CliRunner:  # A runner that calls a command and keeps what it prints
+    """Give each test a runner for the command."""
     return CliRunner()
 
 
-def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_title(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command prints the title of the page."""
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_invokes_requests_get(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command makes a request."""
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_uses_correct_url(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The request goes to the random page of the English Wikipedia."""
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_fails_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An exception in the request ends the command with exit code 1."""
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_message_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """A failed request is printed as an error message, not a traceback."""
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
 @pytest.mark.e2e
-def test_main_succeeds_in_production(runner: CliRunner) -> None:
+def test_main_succeeds_in_production(
+    runner: CliRunner,  # The runner from the fixture
+) -> None:
+    """The command works against the real Wikipedia."""
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+"""Tests of the library, wikipedia.py."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ import pytest
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
+def test_random_page_uses_given_language(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The language chooses the Wikipedia that is asked."""
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
@@ -13,11 +18,15 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 @pytest.mark.e2e
 def test_random_page_returns_page_in_production() -> None:
+    """The real Wikipedia's answer makes a Page."""
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
 
 
-def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+def test_random_page_handles_validation_error(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An answer that is not a page raises WikipediaError."""
     mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
     with pytest.raises(wikipedia.WikipediaError):
         wikipedia.random_page()
```

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538) shows what the move changes.

Now we make a docs site, because smalldocs also makes a website from Markdown. The site is in `docs/`. It has a
front page, `index.qmd`, and a reference page for each module. Each build writes the reference pages from the code,
before it builds the site. A name in backticks, such as `random_page`, becomes a link to its entry.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site. The front page, `docs/index.qmd`, is
new. A `.qmd` file is Markdown, with a header between two `---` lines that gives the title of the page.

Find `contents: api/*  # the reference pages, which each build makes from the code` in the change of
`docs/_smalldocs.yml`. Then open `docs/index.qmd`, a new file.

Next we change the recipe `docs`, so that `just docs` with no words builds the site, with `smalldocs render docs`.
With words, it runs `smalldocs api` as before. The recipe is now a script of several lines.

Find `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi` in the change of `justfile`.

The move changes these files:

- `docs/_smalldocs.yml`: 17 lines added, 1 removed; the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: 35 lines added; a new file, the front page.
- `justfile`: 5 lines added, 2 removed; with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the site. The sidebar lists the front page, then the reference pages.
  - look at: `contents: api/*  # the reference pages, which each build makes from the code`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/docs/index.qmd): the front page, written by hand.
  - look at: `Each build of the site makes the pages under Reference from the code.`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` builds the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

The change of `docs/_smalldocs.yml`:

```diff
@@ -1,4 +1,20 @@
-# The settings of smalldocs. `api` is the reference, made from the code of the packages
+# The settings of smalldocs. `just docs` builds the site into docs/_site
+project:
+  type: website
+  output-dir: _site
+
+website:
+  title: "wikiapp"
+  sidebar:
+    contents:
+      - index.qmd
+      - section: Reference
+        contents: api/*  # the reference pages, which each build makes from the code
+
+theme: cosmo
+toc: true
+
+# `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
   packages: [wikiapp]
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
```

The change of `justfile`:

```diff
@@ -75,8 +75,11 @@ check *args:
     just test -q --cov-fail-under=90
     just lint-config
 
-# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+# The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
 [group('docs')]
 [no-exit-message]
 docs *args:
-    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
+    #!/usr/bin/env sh
+    if [ "$*" = help ]; then just help docs; exit 0; fi
+    if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
+    exec uv run smalldocs api "$@" --dir docs
```

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

### step-08.6 The README names the tests and the docs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab) shows what the move changes.

Now we bring the table of folders in the README up to date. The README gets `tests/` and `docs/` among the
folders. It also says that `wikipedia.py` is the library and `console.py` the command.

Read the change of `README.md`.

The move changes one file:

- `README.md`: 3 lines added, 1 removed; rows for `tests/` and `docs/`, and the `src/wikiapp/` row names the library and the command.

Files to read:
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the folders.
  - look at: `| The docs site. smalldocs makes its reference from the code |`

The change of `README.md`:

```diff
@@ -30,7 +30,9 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `console.py` is the `wikiapp` command |
+| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `tests/` | The tests. `just test` runs them |
+| `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
 | `.python-version` | The Python version the project uses |
 | `.gitignore` | Everything a run makes, ignored from the first commit on |
```

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

### step-08.7 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f806ffc14ec8d49a03fae320c10058db6d723f5e) shows what the move changes.

Now we add `just docs check` to the recipe `check`, after the tests, and name the docs in the comment above it.

Find `just docs check` in the change of `justfile`, and read the new comment above `check`.

The move changes one file:

- `justfile`: 2 lines added, 1 removed; the docs check in `check`, and the comment.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/f806ffc14ec8d49a03fae320c10058db6d723f5e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/f806ffc14ec8d49a03fae320c10058db6d723f5e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
  - look at: `just docs check`

The change of `justfile`:

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -73,6 +73,7 @@ check *args:
     just lint
     just types
     just test -q --cov-fail-under=90
+    just docs check
     just lint-config
 
 # The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
```

```bash
just check
```

The docs check prints `15 of 15`. Now the git hook refuses a commit that leaves a function, a parameter or a
field without documentation.

## step-09 The library as a package

[The code at step-09](https://github.com/rahuldave/smallwikiapp/tree/step-09)

```bash
just setup
```

The code that asks Wikipedia becomes a package of its own, `wikirandom`, in the same repository. The first move
makes an empty package. The next moves add the code, and make the app use the library. The README and the front
page of the docs change with the app. The last move makes the docs check count the library. Any other program
could then install wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/7a3ba49a14ea0f4e049e19ecb934346025e354cb) shows what the move changes.

Now we make an empty library, `wikirandom`, as a second package in `packages/wikirandom`.
uv can make a second package inside a project. The two packages then form a *workspace*, which has one lockfile
and one `.venv` for both. `uv init --lib --author-from none packages/wikirandom` makes the library.
`--author-from none` keeps uv from writing the author's name and email from git into the library's
`pyproject.toml`.

uv makes `packages/wikirandom/`, with these files in it:

- `pyproject.toml`, the library's own
- `README.md`, empty
- `src/wikirandom/__init__.py`, with an example function, `hello`
- `src/wikirandom/py.typed`, the mark that tells a type checker that the package has types

In the project's `pyproject.toml`, uv adds `[tool.uv.workspace]`. uv copies the Python version from
`.python-version`.

Open `packages/wikirandom/src/wikirandom/__init__.py`, a new file. Find `[tool.uv.workspace]` in the change of
`pyproject.toml`.

Next we give the library's `pyproject.toml` Python 3.11, as the app has, and a description. Its `README.md` gets a
heading and one line of what it is.

Find `requires-python = ">=3.11"` in `packages/wikirandom/pyproject.toml`, a new file. Open
`packages/wikirandom/README.md`, a new file.

Then we make the lockfile again with `uv lock`, for the workspace of two packages.

The move changes these files:

- `packages/wikirandom/pyproject.toml`: 11 lines added; new. It has the package's name, version and description, and uv_build.
- `packages/wikirandom/README.md`: 3 lines added; new. It says what the library is.
- `packages/wikirandom/src/wikirandom/__init__.py`: 2 lines added; new. It has uv's example function, `hello`.
- `packages/wikirandom/src/wikirandom/py.typed`: new and empty. It tells ty and other checkers that the package has types.
- `pyproject.toml`: 5 lines added; the workspace, with one member.
- `uv.lock`: 11 lines added; the second package.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`packages/wikirandom/README.md`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/packages/wikirandom/README.md): a heading, and what the library is.
  - look at: ``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/packages/wikirandom/src/wikirandom/__init__.py): uv's example function.
  - look at: `def hello() -> str:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/7a3ba49a14ea0f4e049e19ecb934346025e354cb#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

The change of `pyproject.toml`:

```diff
@@ -74,3 +74,8 @@ select = [
 [tool.ruff.lint.per-file-ignores]
 # A test is written with assert
 "tests/**" = ["S101"]
+
+[tool.uv.workspace]
+members = [
+    "packages/wikirandom",
+]
```

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.

### step-09.2 The code goes into wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2) shows what the move changes.

Now we give the library the code of `src/wikiapp/wikipedia.py`, and the packages that the code imports.
The library needs requests and pydantic. `packages/wikirandom/src/wikirandom/__init__.py` now contains the code of
`src/wikiapp/wikipedia.py`. Its docstring says what the package is. Its User-Agent names the program that makes
the request.

Read the change of `packages/wikirandom/pyproject.toml`. Find
`USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"` in the change of
`packages/wikirandom/src/wikirandom/__init__.py`.

The move changes these files:

- `packages/wikirandom/src/wikirandom/__init__.py`: 41 lines added, 2 removed; the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: 4 lines added, 1 removed; requests and pydantic, which are the library's dependencies.
- `uv.lock`: 10 lines added; the library's dependencies.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/edc2553f27cbaa3ebd3e97452dd74763e0a485e2/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/edc2553f27cbaa3ebd3e97452dd74763e0a485e2/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

The change of `packages/wikirandom/src/wikirandom/__init__.py`:

```diff
@@ -1,2 +1,41 @@
-def hello() -> str:
-    return "Hello from wikirandom!"
+"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
+
+import re
+
+import requests
+from pydantic import BaseModel, ValidationError
+
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
+USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+
+
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
+
+class Page(BaseModel):
+    """A page of Wikipedia: its title and the summary of its text."""
+
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
+
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
+
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
+    try:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
+        ) as response:
+            response.raise_for_status()
+            return Page.model_validate(response.json())
+    except (requests.RequestException, ValidationError) as error:
+        raise WikipediaError(str(error)) from error
```

The change of `packages/wikirandom/pyproject.toml`:

```diff
@@ -4,7 +4,10 @@ version = "0.1.0"
 description = "A random page of Wikipedia, in any language"
 readme = "README.md"
 requires-python = ">=3.11"
-dependencies = []
+dependencies = [
+    "pydantic>=2.14.0",
+    "requests>=2.34.2",
+]
 
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
```

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482) shows what the move changes.

Now we make the library a dependency of the app, in place of requests and pydantic. In the app's code, only
`src/wikiapp/wikipedia.py` imports those two, and it goes later in the move. `tests/test_console.py` still imports
requests, which now comes with wikirandom.

Because wikirandom is a member of the workspace, `uv add` writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. So uv installs the library from `packages/wikirandom`, and not from PyPI. A change to the
library's code then takes effect in the app with no new install. `src/wikiapp/console.py` imports from the
library. The import goes with the installed packages, under `import click`, so the lines are already in ruff's
order.

Find `wikirandom = { workspace = true }` in the change of `pyproject.toml`. Find
`from wikirandom import WikipediaError, random_page` in the change of `src/wikiapp/console.py`.

Next we delete `src/wikiapp/wikipedia.py`, and rename `tests/test_wikipedia.py` to `tests/test_wikirandom.py`.

Next we make the renamed file, `tests/test_wikirandom.py`, test the library.
Its docstring is `Tests of the library, wikirandom.`, and it imports
`wikirandom` under `import pytest`. Its tests call `wikirandom.random_page`, `wikirandom.Page` and
`wikirandom.WikipediaError`. The host `es.wikipedia.org` in the first test stays as it was.

Open `tests/test_wikirandom.py`, the file renamed from `tests/test_wikipedia.py`. Find `import wikirandom` in
it.

Then we make coverage, in `pyproject.toml`, measure both packages.

Find `addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"` in the change of
`pyproject.toml`.

Last, we add a row for the library to `README.md`, and make the front page, `docs/index.qmd`, name two
packages.
The library's README now says that the app uses the library, and no longer that it will.

Read the change of `README.md`, of `docs/index.qmd` and of `packages/wikirandom/README.md`.

The move changes these files:

- `pyproject.toml`: 6 lines added, 4 removed; wikirandom in, requests and pydantic out. The source of wikirandom is the workspace, and coverage measures both packages.
- `uv.lock`: 2 lines added, 4 removed; the app's dependencies are now click and wikirandom.
- `src/wikiapp/console.py`: 1 line added, 1 removed; imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted, 41 lines.
- `tests/test_wikirandom.py`: 7 lines added, 8 removed; renamed from `tests/test_wikipedia.py`, and it tests wikirandom.
- `README.md`: 2 lines added, 1 removed; a row for the library, and the `src/wikiapp/` row says the app.
- `docs/index.qmd`: 8 lines added, 7 removed; two packages, the library and the app.
- `packages/wikirandom/README.md`: 1 line added, 1 removed; says that wikiapp uses the library now.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `The code has two packages, in one repository:`
- [`packages/wikirandom/README.md`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/packages/wikirandom/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-67c60576149738029c3a79bb8233bfb2720f590c0a16b6e4a7dab774bf98d1f9): the library's README says that the app uses it.
  - look at: ``A random page of Wikipedia, in any language. The command `wikiapp` uses this library.``

The change of `pyproject.toml`:

```diff
@@ -9,8 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "pydantic>=2.14.0",
-    "requests>=2.34.2",
+    "wikirandom",
 ]
 
 [project.scripts]
@@ -39,10 +38,10 @@ build-backend = "uv_build"
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
 # marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
 # just test -m e2e
-addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
 markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
@@ -79,3 +78,6 @@ select = [
 members = [
     "packages/wikirandom",
 ]
+
+[tool.uv.sources]
+wikirandom = { workspace = true }
```

The change of `src/wikiapp/console.py`:

```diff
@@ -3,9 +3,9 @@
 import textwrap
 
 import click
+from wikirandom import WikipediaError, random_page
 
 from wikiapp import __version__
-from wikiapp.wikipedia import WikipediaError, random_page
 
 
 @click.command()
```

The change of `README.md`:

```diff
@@ -30,7 +30,8 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `src/wikiapp/` | The app. `console.py` is the `wikiapp` command |
+| `packages/wikirandom/` | The library the app uses: a random page of Wikipedia. A package of its own |
 | `tests/` | The tests. `just test` runs them |
 | `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
```

The change of `docs/index.qmd`:

````diff
@@ -16,13 +16,14 @@ Le Changement démocratique est un parti politique salvadorien fondé en
 2005.
 ```
 
-The code has two modules:
-
-- `wikiapp.wikipedia`, the library. `random_page` asks Wikipedia for a random page and returns a
-  `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a language
-  code, if the request fails, or if the answer is not a page. The library knows nothing of the command line.
-- `wikiapp.console`, the app. `main` is the command. It reads `--language`, calls `random_page`, and
-  prints the page, or the error.
+The code has two packages, in one repository:
+
+- `wikirandom`, the library, in `packages/wikirandom`. `random_page` asks Wikipedia for a random page
+  and returns a `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a
+  language code, if the request fails, or if the answer is not a page. The library knows nothing of the
+  command line.
+- `wikiapp`, the app. `main`, in `wikiapp.console`, is the command. It reads `--language`, calls
+  `random_page`, and prints the page, or the error.
 
 Each build of the site makes the pages under Reference from the code. A page takes these parts from
 each function:
````

The change of `packages/wikirandom/README.md`:

```diff
@@ -1,3 +1,3 @@
 # wikirandom
 
-A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
+A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

```bash
just test -q
uv tree --depth 2
just docs check
just docs
```

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`. `uv tree` shows that wikiapp needs click and wikirandom, and
that wikirandom needs requests and pydantic. `just docs check` still counts the app and the tests alone, 12 of 12. `just docs`
writes 2 pages, the front page and the reference page of the app. The front page names both packages, but
`random_page` is not yet a link, because the settings of the site name only the app. The next move adds the
library to the settings.

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a248f43de21ce0b11b11c2b31e8e8e656c2ba465) shows what the move changes.

Now we make the docs check count the library, in `docs/_smalldocs.yml`.
Since step-09.3, the app uses the library `wikirandom`, a package of its own in `packages/wikirandom`. But
`docs/_smalldocs.yml` names only `wikiapp`. The line `packages:` in the section `api` now names both.

Read the change of `docs/_smalldocs.yml`.

The move changes one file:

- `docs/_smalldocs.yml`: 1 line added, 1 removed; two packages.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/a248f43de21ce0b11b11c2b31e8e8e656c2ba465/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/a248f43de21ce0b11b11c2b31e8e8e656c2ba465#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the list.
  - look at: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

The change of `docs/_smalldocs.yml`:

```diff
@@ -16,6 +16,6 @@ toc: true
 
 # `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
-  packages: [wikiapp]
+  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
   check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

```bash
just docs check
just docs
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry. `just check` passes.

## step-10 Build

[The code at step-10](https://github.com/rahuldave/smallwikiapp/tree/step-10)

```bash
just setup
```

The moves of this step build each package into a wheel, the file that pip and uv install. Then the app says
which versions of the library it accepts, and `just lint-config` checks the library's `pyproject.toml` too.
Both packages say their licence and where their source is. Last, the
library's User-Agent says the version that is installed.

### step-10.1 The recipe `build`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/14aed169df3350fa2bf674e896bdf6921cf4efcf) shows what the move changes.

Now we add a recipe, `build`, at the end of the `justfile`, that builds both packages. It runs
`uv build --all-packages`, which builds every package of the workspace into `dist/`. `.gitignore` lists `dist/`.

Read the change of `justfile`.

The move changes one file:

- `justfile`: 6 lines added; the recipe `build`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/14aed169df3350fa2bf674e896bdf6921cf4efcf/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/14aed169df3350fa2bf674e896bdf6921cf4efcf#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `build *args:`

The change of `justfile`:

```diff
@@ -84,3 +84,9 @@ docs *args:
     if [ "$*" = help ]; then just help docs; exit 0; fi
     if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
     exec uv run smalldocs api "$@" --dir docs
+
+# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
+[group('setup')]
+[no-exit-message]
+build *args:
+    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

```bash
uv build --all-packages
just --show build
just build
unzip -l dist/wikiapp-0.1.0-py3-none-any.whl
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

`dist/` now has a source archive, `.tar.gz`, and a wheel, `.whl`, for each package. The app's wheel contains
`wikiapp/` and its metadata, which says that the app needs click and wikirandom. The metadata does not say which
version of wikirandom, because `uv add wikirandom` in a workspace writes no version. An install from PyPI would
get any package that PyPI has under that name. Today PyPI has none, so wikirandom would have to be published
first.

### step-10.2 The app needs wikirandom 0.1

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29) shows what the move changes.

Now we give the app's dependency on wikirandom a range of versions, `>=0.1.0,<0.2`. Until now, the app's wheel
says that the app needs `wikirandom`, of any version. An install from PyPI would take any package that anyone
publishes under that name. The app works with wikirandom 0.1.0, and `<0.2` keeps out a later release that may
change the library.

Find `"wikirandom>=0.1.0,<0.2",` in the change of `pyproject.toml`.

Nothing else changes in the workspace. uv still installs the library from `packages/wikirandom`, as
`[tool.uv.sources]` says.

The move changes one file:

- `pyproject.toml`: 1 line added, 1 removed; a version range on wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

The change of `pyproject.toml`:

```diff
@@ -9,7 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "wikirandom",
+    "wikirandom>=0.1.0,<0.2",
 ]
 
 [project.scripts]
```

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5680a827b9d6a412d145df259dd161119c4cd776) shows what the move changes.

Now we make `just lint-config` check the library's `pyproject.toml` too.
Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. The
recipe `lint-config` now gives validate-pyproject both files.

Read the change of `justfile`.

The move changes one file:

- `justfile`: 1 line added, 1 removed; `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5680a827b9d6a412d145df259dd161119c4cd776/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/5680a827b9d6a412d145df259dd161119c4cd776#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

The change of `justfile`:

```diff
@@ -58,7 +58,7 @@ lint-config *args:
     #!/usr/bin/env sh
     set -e
     if [ "$*" = help ]; then just help lint-config; exit 0; fi
-    uv run validate-pyproject pyproject.toml
+    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
     uv lock --check
     just --fmt --check --unstable
 
```

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.

### step-10.4 A licence and a repository link for both

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800) shows what the move changes.

Now we give the library a licence and an author, and both packages a link to the repository.
The library's wheel has no licence, and neither package says where its source is. The library gets a copy of the
project's `LICENSE`. Its `pyproject.toml` gives the licence and the author under `readme`, as the app's
`pyproject.toml` does. Both `pyproject.toml` files now name the repository, in `[project.urls]`. PyPI shows it on
the package's page.

Open `packages/wikirandom/LICENSE`, a new file. Read the change of `packages/wikirandom/pyproject.toml` and of
`pyproject.toml`.

The move changes these files:

- `packages/wikirandom/LICENSE`: 202 lines added; new. It has the same licence as the app.
- `packages/wikirandom/pyproject.toml`: 6 lines added; the licence, the author, the repository.
- `pyproject.toml`: 3 lines added; the repository.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): what PyPI would show.
  - look at: `license = "Apache-2.0"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app's repository.
  - look at: `[project.urls]`
- [`packages/wikirandom/LICENSE`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/packages/wikirandom/LICENSE): the same Apache-2.0 licence as the app's.
  - look at: `Apache License`

The change of `packages/wikirandom/pyproject.toml`:

```diff
@@ -3,12 +3,18 @@ name = "wikirandom"
 version = "0.1.0"
 description = "A random page of Wikipedia, in any language"
 readme = "README.md"
+license = "Apache-2.0"
+license-files = ["LICENSE"]
+authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "pydantic>=2.14.0",
     "requests>=2.34.2",
 ]
 
+[project.urls]
+Repository = "https://github.com/rahuldave/smallwikiapp"
+
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
```

The change of `pyproject.toml`:

```diff
@@ -15,6 +15,9 @@ dependencies = [
 [project.scripts]
 wikiapp = "wikiapp.console:main"
 
+[project.urls]
+Repository = "https://github.com/rahuldave/smallwikiapp"
+
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
```

```bash
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.5 The User-Agent says the installed version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1c85536347dae57de53a25fc84b7797180a6ae27) shows what the move changes.

Now we make the library's User-Agent say the installed version.
The User-Agent says `0.1.0`, written by hand. It would still say `0.1.0` after a change of the version in
`packages/wikirandom/pyproject.toml`. `packages/wikirandom/src/wikirandom/__init__.py` now reads the version
from the installed package, as `wikiapp --version` does. `import importlib.metadata` comes above `import re`, in
the same block. `VERSION` is the installed version, and `USER_AGENT` contains it.

Find `import importlib.metadata` and `VERSION = importlib.metadata.version("wikirandom")` in the change of
`packages/wikirandom/src/wikirandom/__init__.py`.

The move changes one file:

- `packages/wikirandom/src/wikirandom/__init__.py`: 3 lines added, 1 removed; the package reads its version once, when Python imports it.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/1c85536347dae57de53a25fc84b7797180a6ae27/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/1c85536347dae57de53a25fc84b7797180a6ae27#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the version now comes from one place, pyproject.toml.
  - look at: `VERSION = importlib.metadata.version("wikirandom")`

The change of `packages/wikirandom/src/wikirandom/__init__.py`:

```diff
@@ -1,5 +1,6 @@
 """wikirandom: a random page of Wikipedia, in any language, from its REST API."""
 
+import importlib.metadata
 import re
 
 import requests
@@ -7,7 +8,8 @@ from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
-USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+VERSION = importlib.metadata.version("wikirandom")
+USER_AGENT = f"wikirandom/{VERSION} (https://github.com/rahuldave/smallwikiapp)"
 
 
 class WikipediaError(Exception):
```

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
