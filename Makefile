# Shortcuts for the local stack. Run `make help` to list them.
COMPOSE := docker compose -f compose.dev.yml

.PHONY: help setup up down logs ps build rebuild reset test-backend sh-backend psql

help: ## List commands
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: ## First-time setup: create .env and workspace links
	@test -f .env || (cp .env.example .env && echo "Created .env from .env.example")
	@./scripts/setup-workspace.sh

up: setup ## Start everything (detached)
	$(COMPOSE) up -d --build
	@echo ""
	@echo "  Site      http://localhost:4321"
	@echo "  Admin     http://localhost:5173"
	@echo "  API docs  http://localhost:8000/docs"
	@echo "  Mailpit   http://localhost:8025"

down: ## Stop everything (keeps data)
	$(COMPOSE) down

logs: ## Follow logs (e.g. make logs s=backend)
	$(COMPOSE) logs -f $(s)

ps: ## Show service status
	$(COMPOSE) ps

rebuild: ## Rebuild after dependency changes (refreshes node_modules volumes)
	$(COMPOSE) up -d --build --renew-anon-volumes

reset: ## DANGER: stop everything and delete all local data
	$(COMPOSE) down -v

test-backend: ## Run backend tests inside the container
	$(COMPOSE) exec backend pytest -q

sh-backend: ## Shell into the backend container
	$(COMPOSE) exec backend sh

psql: ## Open psql on the local database
	$(COMPOSE) exec postgres sh -c 'psql -U $$POSTGRES_USER -d $$POSTGRES_DB'
