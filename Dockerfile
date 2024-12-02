# Run tests in a Docker container to avoid any interference from existing
# settings and plugins.

ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && \
  apt-get install --yes curl git pipx vim neovim && \
  rm -rf /var/lib/apt/lists/*

# Ensure that `vim` doesn't point to `nvim` on Ubuntu
RUN update-alternatives --set vim /usr/bin/vim.basic

RUN useradd --create-home vimmer
USER vimmer

WORKDIR /home/vimmer

# Install linter
RUN pipx install git+https://github.com/Vimjas/vint.git

# Copy Vim/Neovim configuration
COPY --chown=vimmer:vimmer test/docker.vimrc .vimrc
COPY --chown=vimmer:vimmer test/docker.vimrc .config/nvim/init.vim

# Install `vim-plug` plugin manager, then install plugins
RUN vim +qall && vim -es -u .vimrc -i NONE +PlugInstall +qall
RUN nvim +qall && nvim -E -s -u .config/nvim/init.vim +PlugInstall +qall

# Copy (possibly modified) plugin, instead of pulling latest release from GitHub
COPY --chown=vimmer:vimmer ./ plugged/link.vim/

WORKDIR /home/vimmer/plugged/link.vim

# Lint
RUN /home/vimmer/.local/bin/vint ./

# Run tests
RUN vim '+Vader! **/*.vader'
RUN nvim '+Vader! **/*.vader'

CMD [ "echo", "Success" ]
