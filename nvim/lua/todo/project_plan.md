## Project Todos – Implementation Plan

### Goals (project scope only)
- Store todos per project (detected via Git root).
- Add todos from the current buffer with `:Todop`, saving the file path.
- Keep data under Neovim data dir, not inside repos.
- Optional Telescope picker for project tasks only.

### Storage layout
- Base dir: `stdpath('data')/todo/`
- Project file: `stdpath('data')/todo/projects/<project-name>/todos.json`
- `<project-name>` = basename of Git root directory
- Optional metadata file for debugging: `stdpath('data')/todo/projects/<project-name>/project.txt` with the absolute Git root path
- Backups: `todos.backup.json` alongside the JSON

### Project-name derivation
- Compute `project_name = basename(<git-root>)`.
- If Git root cannot be found, commands that require a project should error with guidance.

### Data model (per project)
- Each project has one JSON with per-file task arrays and an optional `inbox` array.
- Timestamps are epoch seconds; UI displays planned date as DD-MM-YY.

#### JSON structure (example)
```json
{
  "version": 1,
  "project": {
    "name": "myapp",
    "root": "/abs/path/to/myapp"
  },
  "meta": {
    "updated_at": 1726392000
  },
  "inbox": [
    {
      "id": "p_1726391800_4821",
      "text": "General project task not tied to a file",
      "done": false,
      "created": 1726391800,
      "modified": 1726391800,
      "priority": "B",
      "planned_at": 1726617600,
      "tags": ["planning"]
    }
  ],
  "files": {
    "src/module/feature.lua": [
      {
        "id": "t_1726391700_9123",
        "text": "Refactor parse logic",
        "done": false,
        "created": 1726391700,
        "modified": 1726391700,
        "priority": "A",
        "planned_at": 1726876800,
        "tags": ["refactor", "performance"]
      },
      {
        "id": "t_1726391750_7742",
        "text": "Add unit tests for edge cases",
        "done": true,
        "created": 1726391750,
        "modified": 1726478150,
        "priority": null,
        "planned_at": null,
        "tags": ["test"]
      }
    ],
    "README.md": [
      {
        "id": "t_1726391766_5190",
        "text": "Document setup for contributors",
        "done": false,
        "created": 1726391766,
        "modified": 1726391766,
        "priority": "C",
        "planned_at": 1727040000,
        "tags": ["docs"]
      }
    ]
  }
}
```

### Commands (project-only)
- `:Todop add <text> [!P] [^DD-MM-YY|^+N|^DD] [#tag ...]`
  - Adds a task to the current project's JSON under the current buffer's file path (relative to Git root when possible).
  - Creates `stdpath('data')/todo/projects/<project-name>/todos.json` on first use.
- `:Todop general <text> [!P] [^DD-MM-YY|^+N|^DD] [#tag ...]`
  - Adds a general project task (not tied to any file) into the project's `inbox` array.
- Short aliases (easier):
  - `:Pt <text> [...]` → alias of `:Todop add <text> [...]` (file-scoped task)
  - `:Pi <text> [...]` → alias of `:Todop general <text> [...]` (project inbox task)
- `:Todop init`
  - Initializes project storage: creates the project dir, an empty `todos.json` if missing, and `project.txt` with the absolute Git root path.

### Parsing rules (project commands)
- Priority: `!A|!B|!C` (first valid wins)
- Planned date (no time; store epoch at local midnight; display DD-MM-YY):
  - `^DD-MM-YY` → absolute date (two-digit year)
  - `^+N` → N days from now
  - `^DD` → day-of-month shorthand: current month if not passed; otherwise next month (clamp to month length)
- Tags: `#tag` tokens; collect all
- Remaining tokens join into `text`
- Invalid date tokens are ignored (no `planned_at` set)

### Sorting
- Pending first → earlier `created` → `text` alphabetical

### Telescope (optional; projects-only)
- Command: `:Todop pick`
- Source: only the current project's JSON
- Entry: `[ ]/✓  text  (!A)  ^DD-MM-YY  #tags  · file`
- Actions: toggle, edit, set/clear priority, set/clear planned, retag, delete
- Filters: status, priority, planned (today/overdue/upcoming)

### Migration & compatibility
- If a legacy global `stdpath('data')/todos.json` exists, keep it separate; this plan covers project files only.
- Version field is recommended to allow future migrations but can be omitted if you prefer—at the cost of brittle migrations.

### Testing checklist
- `:Todop init` creates directories and files correctly; `project.txt` has the right path
- Adding via `:Todop` places the task under the correct relative file key
- Planned date parsing for `^DD-MM-YY`, `^+N`, and `^DD`
- Telescope picker (if enabled) reflects operations and persists changes


