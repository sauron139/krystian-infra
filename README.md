# krystian-infra

Local environment, deployment and shared docs for Krystian's portfolio platform.

- `WORKSPACE.md` is the system overview (linked as `../CLAUDE.md`).
- `docs/` holds the brief, design, architecture and API contract (linked as `../docs`).

## Workspace layout
Clone the four repos side by side:
```
krystian/
├── krystian-backend/
├── krystian-frontend/
├── krystian-admin/
└── krystian-infra/     ← run commands from here
```

## Local development
Requires Docker Desktop.
```
make up      # build and start everything
make ps      # status
make logs s=backend
make down
make help    # all commands
```

| Service | URL |
|---------|-----|
| Site | http://localhost:4321 |
| Admin | http://localhost:5173 |
| API docs | http://localhost:8000/docs |
| Mailpit | http://localhost:8025 |

After changing dependencies in an app (`package.json`, `pyproject.toml`), run `make rebuild`.
