#!/usr/bin/env python3

# Helper script for status printing
import sys
import time
import subprocess
from enum import Enum
from pathlib import Path
from argparse import ArgumentParser


class Level(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"


class Icon(Enum):
    CLEAN = "clean"
    BUILD = "build"
    TARGET = "target"
    FOLDER = "folder"
    ERROR = "error"
    SETUP = "setup"
    GIFT = "gift"
    SLEEP = "sleep"
    MULTI = "multi"
    BRANCH = "branch"
    SYNC = "sync"


# Map icons enum to real icons
ICONS = {
    Icon.BUILD: "\U0001F6E0 ",
    Icon.CLEAN: "\U0001F9F9 ",
    Icon.TARGET: "\U0001F3AF ",
    Icon.FOLDER: "\U0001F4C2 ",
    Icon.ERROR: "\U0001F480 ",
    Icon.SETUP: "\U0001F680 ",
    Icon.GIFT: "\U0001F381 ",
    Icon.SLEEP: "\U0001F4A4 ",
    Icon.MULTI: "\U0001F500 ",
    Icon.BRANCH: "\U0001F33F ",
    Icon.SYNC: "\U0001F300 ",
}


class Styles:
    BOLD = "\u001b[1m"
    RESET = "\u001b[0m"
    YELLOW = "\u001b[93m"
    RED = "\u001b[91m"
    GREEN = "\u001b[32m"
    BLUE = "\u001b[34m"


# Map levels to colors
LVL_STYLES = {Level.INFO: Styles.RESET, Level.WARNING: Styles.YELLOW, Level.ERROR: Styles.RED}


def pretty_print(stamp: str, icon: Icon, name: str, target: str, level: Level, status: str):
    print(
        f"{Styles.GREEN}{stamp}{Styles.RESET} {ICONS[icon]} {Styles.BOLD}{ICONS[Icon.FOLDER]}{name} {ICONS[Icon.TARGET]}{target} {Styles.BLUE}-{Styles.RESET} {LVL_STYLES[level]}{status}{Styles.RESET}"
    )


def main():
    # Parse args
    parser = ArgumentParser(description="Helper script for status printing")
    parser.add_argument("-w", "--workspace", type=Path, help="Path to workspace root")
    parser.add_argument("-p", "--project", type=Path, required=True, help="Path to project root")
    parser.add_argument("-s", "--status", required=True, help="Status to be displayed")
    parser.add_argument("-l", "--level", type=Level, default=Level.INFO, help="Color level")
    parser.add_argument("-i", "--icon", type=Icon, required=True, help="Displayed emoji")
    parser.add_argument("-t", "--target", type=Path, required=True, help="Current make target")
    parser.add_argument("-o", "--output", type=Path, default=Path("/tmp/build-logs"), help="Output path for logs")
    args, cmd = parser.parse_known_args(sys.argv[1:])

    # Reckon project name and target
    p_path = args.project.resolve()
    w_path = args.workspace.resolve() if args.workspace is not None else None
    if p_path == w_path:
        name = "<root>"
    else:
        name = str(p_path.relative_to(w_path)) if w_path is not None else p_path.name
    target = args.target.name

    # Get time
    stamp = time.strftime("%H-%M-%S", time.localtime())

    # Print status
    pretty_print(stamp, args.icon, name, target, args.level, args.status)

    # Is there something to run?
    if len(cmd) > 0:
        # Clean output directory
        output: Path = args.output
        output.mkdir(parents=True, exist_ok=True)

        # Run process and redirect outputs
        out = output / f"{stamp}-{name}-{target}.out"
        err = output / f"{stamp}-{name}-{target}.err"
        with out.open("w") as o, err.open("w") as e:
            rc = subprocess.call(cmd, stdout=o, stderr=e)

        # Something went wrong?
        if rc != 0:
            stamp = time.strftime("%H-%M-%S", time.localtime())
            pretty_print(stamp, Icon.ERROR, name, target, Level.ERROR, f"!!! ERROR !!! -- see output in {out}")
            with err.open("r") as e:
                print(e.read())
            sys.exit(rc)


if __name__ == "__main__":
    main()
