# Tests

## Workstation

To run the tests on your workstation, use the `run_tests.sh` script. Run it with
the `-h` flag to view its available options.

## Docker

Build the Docker image:
`docker image build --build-arg BASE_IMAGE=debian:bookworm-slim -t link.vim ./`
Another possible value for `BASE_IMAGE` is for instance `ubuntu:24.04`.

Run the container to lint the source code and execute the tests in both Vim and
Neovim: `docker container run -it --rm link.vim`

If an error occurs, access the container with:
`docker container run -it --rm link.vim bash`
Once inside, lint the code manually: `~/.local/bin/vint ~/plugged/link.vim/`
Run the tests manually: `:Vader **/*.vader`

## Misc

The tests that involve opening a URL in a browser will always fail in a Docker
container. These tests are marked with the `FIXME` label to prevent them from
affecting the exit status.

The following Vim and Neovim versions are supported:

```text
                         Vim      Neovim
Ubuntu 22.04 (Jammy)     8.2      0.6.1
Debian 12 (Bookworm)     9.0      0.7.2
Ubuntu 24.04 (Noble)     9.1      0.9.5
```

See the [Vim][1] and [Neovim][2] Repology pages for details.

[1]: https://repology.org/project/vim/versions
[2]: https://repology.org/project/neovim/versions
