.PHONY: help bootstrap test lint format format-fix pdf pre-commit pre-commit-install

help:
	@echo "ML Log Notes Automation"
	@echo ""
	@echo "Targets:"
	@echo "  bootstrap          Create directory structure and test folders for notes and projects"
	@echo "  pdf                Compile a .tex note file into a PDF (usage: make pdf FILE=path/to/note.tex)"
	@echo "  test               Run tests across modules if available"
	@echo "  lint               Run linters (ruff, mypy) across all note directories"
	@echo "  format             Check code formatting with ruff"
	@echo "  format-fix         Automatically format code and fix lint issues"
	@echo "  pre-commit         Run pre-commit checks on all files"
	@echo "  pre-commit-install Install pre-commit git hooks locally"

MODULES := 01-math-foundations 02-classical-ml 03-deep-learning/01-ann 03-deep-learning/02-cnn 03-deep-learning/03-rnn 03-deep-learning/04-generative-ai 03-deep-learning/05-advanced-cv papers projects

bootstrap:
	@echo "==> Bootstrapping ML Log directory structure..."
	@for mod in $(MODULES); do \
		mkdir -p "$$mod/tests"; \
		if [ ! -f "$$mod/README.md" ]; then \
			echo "# $$mod" > "$$mod/README.md"; \
		fi; \
		if [ ! -f "$$mod/tests/.gitkeep" ]; then \
			touch "$$mod/tests/.gitkeep"; \
		fi; \
	done
	@echo "==> Bootstrap complete!"

pdf:
	@if [ ! -f "$(FILE)" ]; then \
		echo "Error: $(FILE) not found."; \
		exit 1; \
	fi
	@echo "==> Compiling $(FILE) to PDF using latexmk..."
	latexmk -pdf -interaction=nonstopmode $(FILE)
test:
	@echo "==> Running test suite across modules..."
	@for mod in 01-math-foundations 02-classical-ml 03-deep-learning/01-ann 03-deep-learning/02-cnn 03-deep-learning/03-rnn 03-deep-learning/04-generative-ai 03-deep-learning/05-advanced-cv papers projects; do \
		if [ -d "$$mod/tests" ] && [ -n "$$($(MAKE) -s -C . 2>/dev/null; find $$mod/tests -name '*.py' 2>/dev/null)" ]; then \
			echo "   -> Testing $$mod"; \
			(cd $$mod && uv run pytest tests -v); \
		fi; \
	done

lint:
	@echo "==> Running linters across all note directories..."
	@for mod in 01-math-foundations 02-classical-ml 03-deep-learning papers projects; do \
		if [ -d "$$mod" ]; then \
			echo "   -> Linting $$mod"; \
			uv run ruff check $$mod; \
		fi; \
	done

format:
	@echo "==> Checking code format..."
	@for mod in 01-math-foundations 02-classical-ml 03-deep-learning papers projects; do \
		if [ -d "$$mod" ]; then \
			echo "   -> Checking format for $$mod"; \
			uv run ruff format --check $$mod && uv run ruff check $$mod; \
		fi; \
	done

format-fix:
	@echo "==> Formatting code and fixing auto-fixable lint issues..."
	@for mod in 01-math-foundations 02-classical-ml 03-deep-learning papers projects; do \
		if [ -d "$$mod" ]; then \
			echo "   -> Formatting $$mod"; \
			uv run ruff format $$mod && uv run ruff check --fix $$mod; \
		fi; \
	done

.PHONY: ci
ci: format-fix format lint test

pre-commit:
	@echo "==> Running pre-commit hooks across repository..."
	uv run pre-commit run --all-files

pre-commit-install:
	@echo "==> Installing pre-commit git hooks..."
	uv run pre-commit install