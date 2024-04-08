#!/usr/bin/env bash

# Run tests in an isolated environment

# Change to script directory
cd "${0%/*}" || exit 1

show_help_and_exit() {
  cat <<EOF >&2
Usage: $(basename "$0") -e <vim/nvim> [-o output.txt] [-f file.vader]
  -e: editor to be used for the tests ('vim' or 'nvim')
  -o: write output to file; optional; by default, output will be shown inside
      Vim/Neovim
  -f: test file(s) to be run; optional; default is all *.vader files; if used,
      must be last flag
EOF
  exit 1
}

while getopts ':e:o:f' OPTION; do
  case "$OPTION" in
    e)
      editor_name="$OPTARG"

      if [[ "$editor_name" != "vim" && "$editor_name" != "nvim" ]]; then
        show_help_and_exit
      fi

      printf "Running tests in: %s\n" "$editor_name"
      editor=$(command -v "$editor_name")
      ;;

    o)
      output_to_file=true
      export VADER_OUTPUT_FILE="$OPTARG"
      ;;

    f)
      all_tests=false
      ;;

     *)
       show_help_and_exit
       ;;
  esac
done
shift "$((OPTIND - 1))"

# -e flag is required
[[ -z "$editor_name" ]] && show_help_and_exit

# Decide if all tests should be run or only one or more particular test(s)
if [[ "$all_tests" != false ]]; then
  test_files='*'
  printf "Running tests in all: *.vader files\n"

else
  test_files="$*"

  # -f requires an argument
  [[ -z "$test_files" ]] && show_help_and_exit

  printf "Running tests in specified files: %s\n" "$test_files"
fi

if [[ "$output_to_file" == true ]]; then
  vader_cmd="Vader!"
else
  vader_cmd="Vader"
fi

# -N         No-compatible mode
# -u {vimrc} Use the commands in the file {vimrc} for initializations
"$editor" -N -u mini.vimrc +"${vader_cmd} ${test_files}"
