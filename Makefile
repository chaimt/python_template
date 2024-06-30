
SHELL=/bin/bash
export APP_NAME=main_code
export BUILD_DIR=$(shell pwd)
export VIRTUAL_ENV=${BUILD_DIR}/.venv
export POETRY_DIR=${BUILD_DIR}/${APP_NAME}
export PYTHON_VERSION=3.10.13


# Colors for echos 
ccend = $(shell tput sgr0)
ccbold = $(shell tput bold)
ccgreen = $(shell tput setaf 2)
ccso = $(shell tput smso)

DEFAULT_GOAL: help

.PHONY: help
help:	
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "${ccbold}Note: to activate the environment in your local shell type:"
	@echo "   $$ source $(VIRTUAL_ENV)/bin/activate"


##@ Development

clean-data: ## >> remove all data files
	@echo ""
	@echo "$(ccso)--> Removing virtual environment $(ccso)"
	rm -rf ${BUILD_DIR}/data/agents  || true	
	rm -rf ${BUILD_DIR}/data/ingestion  || true	
	rm -rf ${BUILD_DIR}/data/load  || true	
	rm -rf ${BUILD_DIR}/data/*.json  || true

clean: ## >> remove all environment and build files
	@echo ""
	@echo "$(ccso)--> Removing virtual environment $(ccso)"
	find ${BUILD_DIR} | grep -E "(/__pycache__$|\.pyc$|\.pyo$|\.pytest_cache$)" | xargs rm -rf
	rm -rf ${BUILD_DIR}/${VIRTUAL_ENV} || true	
	rm -rf ${BUILD_DIR}/target  || true	
	rm -rf ${BUILD_DIR}/logs  || true	
	rm -rf ${BUILD_DIR}/.mypy_cache  || true	
	rm -rf ${BUILD_DIR}/.pytest_cache  || true	
	rm -rf ${BUILD_DIR}/.ruff_cache  || true		
	rm -rf ${BUILD_DIR}/htmlcov || true


setup-env: ## >> setup environment for development
	@echo "$(ccgreen)--> Environment setup $(ccgreen)"
	rm -rf $(VIRTUAL_ENV)  || true &&\
	pyenv local $(PYTHON_VERSION) &&\
	python3 -m venv $(VIRTUAL_ENV) &&\
	source $(VIRTUAL_ENV)/bin/activate &&\
	pip install --upgrade pip &&\
	pip install poetry &&\
	pip install tox &&\
	pip install pre-commit &&\
	pre-commit &&\
	poetry install 

.PHONY: tests
tests: ## run tests
	source $(VIRTUAL_ENV)/bin/activate &&\
	tox


open-tests-results: ## run tests
	open ${BUILD_DIR}/htmlcov/index.html

validate: ## validate project files
	pre-commit run --all-files 
		
build: ## build project
	source $(VIRTUAL_ENV)/bin/activate &&\
	poetry build &&\
	docker build -t ${APP_NAME} .


ide: ## build project
	source $(VIRTUAL_ENV)/bin/activate &&\
	code .

