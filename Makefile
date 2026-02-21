.PHONY: git-hooks help build access lint lint-docker test test-vim test-vim-docker test-nvim test-nvim-docker
.DEFAULT_GOAL := help

CONTAINER := docker container run --rm link.vim
CONTAINER_TTY := docker container run -it --rm link.vim
LINT := vint .
TEST := 'Vader! **/*.vader'

help:
	@echo "Available targets:"
	@echo "  git-hooks          - Set up git hooks for the project"
	@echo "  build              - Build the Docker image"
	@echo "  access             - Access the Docker container"
	@echo "  lint               - Run linter"
	@echo "  lint-docker        - Run linter inside container"
	@echo "  test               - Run tests in Neovim"
	@echo "  test-vim           - Run tests in Vim"
	@echo "  test-vim-docker    - Run tests in Vim inside container"
	@echo "  test-nvim          - Run tests in Neovim"
	@echo "  test-nvim-docker   - Run tests in Neovim inside container"

git-hooks:
	git config core.hooksPath .git_hooks

build:
	docker image build -t link.vim .
access: build
	$(CONTAINER_TTY)

lint:
	$(LINT)
lint-docker: build
	$(CONTAINER) $(LINT)

test:
	./test/run_tests.py -e nvim

test-vim:
	./test/run_tests.py -e vim
test-vim-docker: build
	$(CONTAINER) vim -c $(TEST)

test-nvim:
	./test/run_tests.py -e nvim
test-nvim-docker: build
	$(CONTAINER) nvim -c $(TEST)
