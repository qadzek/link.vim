#!/usr/bin/env bash

# Run tests in an isolated environment

# Change to script directory
cd "${0%/*}" || exit 1

if [[ "$1" == '-v' ]]; then
  editor=$(command -v vim)

elif [[ "$1" == '-n' ]]; then
  editor=$(command -v nvim)

else
  printf 'Add the flag -v to run the tests in Vim\n'    >&2
  printf '             -n to run the tests in Neovim\n' >&2
  exit 1
fi

# -N          No-compatible mode
# -u {vimrc}  Use the commands in the file {vimrc} for initializations
"$editor" -N -u mini.vimrc +Vader*
