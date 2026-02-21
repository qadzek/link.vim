# Run tests in a Docker container to avoid any interference from existing
# settings and plugins.

# hadolint global ignore=DL3001,DL3008,DL3059

# This points to the current Ubuntu LTS release.
ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Install packages.
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      git       \
      pipx      \
      make      \
      vim       \
      neovim && \
    rm -rf /var/lib/apt/lists/*

# Ensure that `vim` doesn't point to `nvim` on Ubuntu.
RUN update-alternatives --set vim /usr/bin/vim.basic

RUN useradd --create-home vimmer
USER vimmer
WORKDIR /home/vimmer
RUN echo "set -o vi" >> /home/vimmer/.bashrc

# Install the Vint linter.
# hadolint ignore=DL3013
RUN pipx install git+https://github.com/Vimjas/vint.git
ENV PATH="/home/vimmer/.local/bin:${PATH}"

# Install the Vader test plugin.
RUN git clone https://github.com/junegunn/vader.vim vader.vim

# Copy the Vim and Neovim configuration files.
COPY --chown=vimmer:vimmer test/minimal.vimrc .vimrc
COPY --chown=vimmer:vimmer test/minimal.vimrc .config/nvim/init.vim

# Copy the link.vim plugin.
COPY --chown=vimmer:vimmer . ./link.vim

WORKDIR /home/vimmer/link.vim

CMD [ "bash" ]
