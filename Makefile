# isort . && black . && bandit -r . && flake8 && pre-commit run --all-files
# Get changed files

FILES := $(wildcard **/*.py)

# if you wrap everything in pipenv run, it runs slower.
ifeq ($(origin VIRTUAL_ENV),undefined)
    VENV := pipenv run
else
    VENV :=
endif

Pipfile.lock: Pipfile
	@echo "Installing dependencies"
	@pipenv install --dev

clean-pyc:
	@echo "Removing compiled files"
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	@echo "Removing coverage data"
	@rm -f .coverage
	@rm -f .coverage.*

clean: clean-pyc clean-test

# tests can't be expected to pass if dependencies aren't installed.
# tests are often slow and linting is fast, so run tests on linted code.
test: clean .build_history/flake8 .build_history/bandit Pipfile.lock
	@echo "Running unit tests"
	$(VENV) python -m unittest discover
	# pipenv run py.test tests --cov=src --cov-report=term-missing --cov-fail-under 95

.build_history:
	@mkdir -p .build_history

.build_history/isort: .build_history $(FILES)
	@echo "Formatting imports"
	$(VENV) isort .
	@touch .build_history/isort

.PHONY: isort
isort: .build_history/isort

.build_history/black: .build_history .build_history/isort $(FILES)
	@echo "Formatting code"
	$(VENV) black .
	@touch .build_history/black

.PHONY: black
black: .build_history/black

.build_history/pre-commit: .build_history .build_history/isort .build_history/black
	@echo "Pre-commit checks"
	$(VENV) pre-commit run --all-files
	@touch .build_history/pre-commit

.PHONY: pre-commit
pre-commit: .build_history/pre-commit

.build_history/bandit: .build_history $(FILES)
	@echo "Security checks"
	$(VENV)  bandit .
	@touch .build_history/bandit

.PHONY: bandit
bandit: .build_history/bandit

.build_history/flake8: .build_history .build_history/isort .build_history/black $(FILES)
	@echo "Linting with flake8"
	$(VENV) flake8 .
	@touch .build_history/flake8

.PHONY: flake8
flake8: .build_history/flake8

# for when using -j (jobs, run in parallel)
.NOTPARALLEL: .build_history/isort .build_history/black

check: test flake8 bandit pre-commit
