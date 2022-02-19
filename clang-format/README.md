# install clang-format

Install `clang-format` first.

```
pip3 install clang-format
```

# vscode config

`open extensions` and install extension named `Clang-Format`.

`open settings` and add this line:

```
"clang-format.executable": "${env.HOME}/.local/bin/clang-format",
```

# copy

copy `google_style.clang-format` to your project source's top directory, and rename as `.clang-format`.

```
cp google_style.clang-format XXX/.clang-format
```

