# Tests

## Docker

The best way to avoid interference from your local Vim/Neovim setup is to run
the tests in a Docker container. The Makefile includes targets to simplify
entering the following commands.

Build the Docker image:

```sh
docker image build -t link.vim .
```

Add e.g. `--build-arg BASE_IMAGE=debian:trixie-slim` to use Debian 13 (Trixie)
as the base image instead of the current Ubuntu LTS.

Run the container in these ways to lint the source code and execute the tests in
both Vim and Neovim:

```sh
docker container run -it --rm link.vim vint .
docker container run -it --rm link.vim vim  -c 'Vader! **/*.vader'
docker container run -it --rm link.vim nvim -c 'Vader! **/*.vader'
```

You can also simply access the container:

```sh
docker container run -it --rm link.vim
```

Then, run the tests from inside Vim/Neovim: `:Vader **/*.vader`.

## Non-Docker

To run the tests on your workstation, use the script `./run_tests.py`. Add the
`-h` flag to view its available options.
An alternative is to start Vim or Neovim with the minimal configuration file:
`nvim -Nu minimal.vimrc` and then run `:Vader **/*.vader`.

## Misc

`link.vim` is based on `wiki.vim` `v0.11`, which requires at least Vim 9.1 or
Neovim 0.10.

The tests seem to pass on some older distributions, though:

```text
                         Vim      Neovim
Ubuntu 22.04 (Jammy)     8.2      0.6.1
Debian 12    (Bookworm)  9.0      0.7.2
Ubuntu 24.04 (Noble)     9.1      0.9.5
Debian 13    (Trixie)    9.1      0.10.4
```

See the [Vim][1] and [Neovim][2] Repology pages for details.

[1]: https://repology.org/project/vim/versions
[2]: https://repology.org/project/neovim/versions
