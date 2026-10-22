# Templates

`launch.json` and `tasks.json` are not user-level global files in VS Code. They only apply inside a
project's own `.vscode/` folder, so these are starting points to copy in.

## Usage

```bash
mkdir -p .vscode
cp templates/launch.json .vscode/launch.json
cp templates/tasks.json .vscode/tasks.json
```

Then delete whichever configurations and tasks do not apply. `launch.json` covers Python, Node,
C and C++ (through `lldb-dap`), Java and Go. `tasks.json` covers a CMake build and configure
pair, npm install and test plus running the current Python file. None of them are meant to all
apply to one project at once.
