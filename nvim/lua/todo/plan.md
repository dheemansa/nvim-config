## Todo Plugin – Feature Plan

### Goals
- **Project-specific todos**: Keep tasks per project (Git root) plus a global inbox.
- **Telescope integration**: Fuzzy search, filter, and act on tasks.
- **Simple command syntax**: Quick capture with priority and planned date parsing.
- **Quality-of-life**: Solid UX, minimal config, fast operations.

### Roadmap (Milestones)
1) Core project scoping and storage
2) Command syntax and parsing (priority, planned date, tags)
3) Telescope picker with actions
4) Inline UX (virtual text, icons), agenda view
5) Recurrence and dependencies (optional, later)

### Project scoping and storage
- **Root detection**: Use `git` root; fallback to `vim.loop.cwd()` or markers like `.project`.
- **Storage location (within Neovim data dir)**:
  - Base dir: `stdpath('data')/todo/`
  - Global file: `stdpath('data')/todo/global/todos.json`
  - Project files: `stdpath('data')/todo/projects/<project-name>/todos.json`
    - `<project-name>` is the basename of the Git root directory (e.g., for `/home/me/code/myapp`, key is `myapp`).
  
#### Project-name derivation
- Compute `project_name = basename(<git-root>)`.
- Optional: create `stdpath('data')/todo/projects/<project-name>/project.txt` with the absolute project path for debugging.
  
### Backups and atomicity
- Backup path per file: alongside JSON as `todos.backup.json` in the same dir.
- Ensure parent directories exist; write with atomic temp file then move.

### Data model (backward compatible)
- Current fields: `id, text, done, created, modified, created_str`
- Add optional fields:
  - `priority`: one of `A|B|C` (string)
  - `planned_at`: unix timestamp (number)
  - `due_at`: unix timestamp (number, optional future feature)
  - `tags`: array of strings (e.g., `['review', 'home']`)
  - `file_path`: path to the originating file when created via project commands (relative to project root preferred; fallback to absolute)

#### Project JSON structure (example)
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

### Command syntax (simple, fast)
- Base capture command: `:TodoNew <text> [!P] [^DD-MM-YY|^+N|^DD] [#tag ...]`
  - **Priority**: `!A`, `!B`, `!C` (defaults to none)
  - **Planned date**:
    - Absolute day: `^DD-MM-YY` (e.g., `^15-09-25`)
    - Relative days: `^+N` (e.g., `^+5` → 5 days from now)
    - Day-of-month shorthand: `^DD` (e.g., `^15` → if the 15th of this month is upcoming, use it; otherwise use the 15th of next month)
  - **Tags**: `#review #home`
- Examples:
  - `:TodoNew Fix flaky test !A ^15-09-25 #ci #backend`
  - `:TodoNew Read spec ^+3`
  - `:TodoNew Pay bills ^15 !B #finance`

### Parsing rules
- Tokenize args; any token starting with:
  - `!` → priority (take the first valid `A|B|C`)
  - `^` → planned date; accept one of:
    - `^DD-MM-YY` (two-digit year)
    - `^+N` (N is integer days from now)
    - `^DD` (day-of-month shorthand; select this month if not passed, otherwise next month)
  - `#` → tag; collect multiple
- Remaining tokens join into the `text`.
- Date parsing:
  - Parse `DD-MM-YY` by splitting tokens and building an `os.time` table; validate ranges.
  - `+N` uses `os.time()` + `N*86400` normalized to midnight local.
  - `DD` computes a target date at local midnight with the month rollover rule above.
  - Fallback to omitting `planned_at` if invalid.


### UI/UX enhancements
- Inline virtual text: show priority `(!A)` and planned date `^DD-MM-YY` in the menu.
- Agenda view: `:TodoAgenda` shows Today, Tomorrow, Week with planned tasks; jump to task.
- Statusline counters: pending/overdue for current scope via a small API function.

### Config additions
- `telescope = { enable = true }`
- `date_formats = { '%d-%m-%y' }` (display only; storage uses epoch)
- `priority_levels = { 'A', 'B', 'C' }`
- `auto_delete_completed_after_24h = false` (already implemented)

### Commands and keymaps
- `:TodoNew ...` (with parsing)
- `:Todop <text> [!P] [^DD-MM-YY|^+N|^DD] [#tag ...]` → add to current project's todos file; creates `stdpath('data')/todo/projects/<project-name>/todos.json` on first use. Adds `file_path` from current buffer.
- `:Todop init` → initialize project storage (create dir, empty `todos.json` if missing, and `project.txt` with absolute project root path)
- `:TodoMenu` (existing)
- `:TodoProjectMenu` → menu scoped to current project
- `:TodoList [pending|done] [--scope project|global|both]`
- `:TodoProjectList [pending|done]` → list from current project's store only
- `:TodoTelescope [scope]`
- Keymaps inside menu:
  - `p` → cycle priority A→B→C→none
  - `P` → prompt exact priority
  - `^` → set planned date; `\` to clear
  - `t` → add tag; `T` → remove tag

### Implementation notes
- Refactor storage to support loading two arrays (global + project) and merge for views when needed.
- Ensure all mutations target the correct backing file according to the task’s source.
- Keep sorting fixed (pending → created → text) with additional tie-breakers: priority (A highest) and sooner `planned_at` first when present.
- Maintain performance: lazy-load project file, debounce saves, reuse existing `save_todos_async` pattern.
  
#### Project command specifics
- When running `:Todop`:
  - Detect Git root; if not in a Git project, show a friendly error suggesting `:TodoNew` or `:TodoScope set global`.
  - Build project path: `stdpath('data')/todo/projects/<project-name>/todos.json`; ensure parent dirs exist.
  - Capture `file_path`:
    - Prefer path relative to Git root of the current buffer (`vim.fn.fnamemodify(bufname, ':~:.')` like logic with root).
    - If computation fails, use absolute path.
  - Save task into the project file with the same schema as global, plus `file_path`.
  - Display will show a short filename hint, e.g., `filename.lua: task text` or via virtual text `· file`.

- When running `:Todop init`:
  - Detect Git root; if missing, show an error.
  - Create `stdpath('data')/todo/projects/<project-name>/` directory if absent.
  - Create `todos.json` with an empty array `[]` if missing.
  - Write `project.txt` with the absolute Git root path for reference.
  - Notify the user of the initialized location.

### Migration and compatibility
- If existing `stdpath('data')/todos.json` is found, migrate it to `stdpath('data')/todo/global/todos.json` on first run (and keep a backup).
- Any legacy project files in repos (if previously used) can be imported manually into `stdpath('data')/todo/projects/<project-name>/todos.json`.
- New fields are optional; parser only adds them when specified.
- No breaking changes to current commands.

### Milestone breakdown
- M1: Scope detection, project file IO, scope config
- M2: Parser for `:TodoNew` args → fields
- M3: Telescope picker + actions
- M4: Menu UX for priority/planned/tags, agenda view
- M5: Sorting enhancement with priority/planned tie-breakers

### Testing checklist
- Add tasks with/without priority/planned; verify persistence and display.
- Switch between project/global scopes; ensure isolation and correct mutations.
- Telescope actions round-trip (toggle, edit, delete) and reflect in files.
- Agenda shows planned tasks correctly (today/upcoming/overdue).


