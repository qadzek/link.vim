#!/usr/bin/env python3

"""Run link.vim tests."""

import argparse
import os
import subprocess
from dataclasses import dataclass
from pathlib import Path

VIMRC = "minimal.vimrc"


@dataclass
class Args:
    """Command line arguments."""

    browser: bool
    editor: str
    files: list[str]
    output: str | None


def parse_args() -> Args:
    """Parse command line arguments."""

    parser = argparse.ArgumentParser(description="Run link.vim tests.")

    parser.add_argument(
        "-b",
        "--browser",
        help="open links in browser",
        action="store_true",
    )
    parser.add_argument(
        "-e",
        "--editor",
        help="editor in which tests will be run",
        choices=["vim", "nvim"],
        default="nvim",
    )
    parser.add_argument(
        "-f",
        "--files",
        help="test file(s) to be run; default is all",
        nargs="+",
        default=["**/*.vader"],
    )
    parser.add_argument(
        "-o",
        "--output",
        help="write output to specified file; by default, output is shown in editor",
        type=str,
        metavar="FILE",
    )

    parsed = parser.parse_args()
    return Args(**vars(parsed))


def main():
    os.chdir(Path(__file__).resolve().parent)

    args = parse_args()

    vader_cmd = "Vader"

    if args.browser:
        os.environ["TEST_OPEN_IN_BROWSER"] = "true"

    if args.output:
        os.environ["VADER_OUTPUT_FILE"] = args.output
        # Exit editor after running the tests with exit status of 0 or 1
        vader_cmd = "Vader!"

    subprocess_arguments = [
        args.editor,
        "-N",
        "-u",
        VIMRC,
        "-c",
        f"{vader_cmd} {' '.join(args.files)}",
    ]

    subprocess.run(
        subprocess_arguments,
        check=False,
    )


if __name__ == "__main__":
    main()
