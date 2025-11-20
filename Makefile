.PHONY: build access lint lint-docker test test-vim test-vim-docker test-nvim test-nvim-docker
.DEFAULT_GOAL := lint

CONTAINER := docker container run --rm link.vim
CONTAINER_TTY := docker container run -it --rm link.vim
LINT := vint .
TEST := 'Vader! **/*.vader'

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
