"""
Some shared functions for helpers
"""
import time
import subprocess
import sys
from enum import Enum
from pathlib import Path


# Icon names
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
    PUZZLE = "puzzle"
    FLOPPY = "floppy"
    RIGHT_FINGER = "right_finger"


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
    Icon.PUZZLE: "\U0001F9E9 ",
    Icon.FLOPPY: "\U0001F4BE ",
    Icon.RIGHT_FINGER: "\U0001F449 ",
}


# Status level
class Level(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"


# ANSI styling
class Styles:
    BOLD = "\u001b[1m"
    RESET = "\u001b[0m"
    YELLOW = "\u001b[93m"
    RED = "\u001b[91m"
    GREEN = "\u001b[32m"
    BLUE = "\u001b[34m"


# Map levels to colors
LVL_STYLES = {Level.INFO: Styles.RESET, Level.WARNING: Styles.YELLOW, Level.ERROR: Styles.RED}


# Get current timestamp string
def get_stamp():
    return time.strftime("%H:%M:%S", time.localtime())


# Pretty print function
def pretty_print(stamp: str, icon: Icon, name: str, target: str, level: Level, status: str):
    print(
        f"{Styles.GREEN}{stamp}{Styles.RESET} "  # Timestamp
        + f"{ICONS[icon]} "  # Action icon
        + f"{Styles.BOLD}{ICONS[Icon.FOLDER]}{name} "  # Folder (project)
        + f"{ICONS[Icon.TARGET]}{target} "  # Current target name
        + f"{Styles.BLUE}-{Styles.RESET} "  # Separator
        + f"{LVL_STYLES[level]}{status}{Styles.RESET}"  # Status string
    )


# Prompt function
def prompt_user(question: str) -> bool:
    answer = input(f" {ICONS[Icon.RIGHT_FINGER]} {Styles.YELLOW}{question} (Y/n)?{Styles.RESET} ")
    return len(answer) == 0 or answer.capitalize()[0] == "Y"


# Common arguments for helpers
def add_common_args(parser):
    parser.add_argument("-w", "--workspace", type=Path, help="Path to workspace root")
    parser.add_argument("-p", "--project", type=Path, required=True, help="Path to project root")
    parser.add_argument("-t", "--target", type=Path, required=True, help="Current make target")
    parser.add_argument("-o", "--output", type=Path, default=Path("/tmp/build-logs"), help="Output path for logs")
    parser.add_argument("-v", "--verbose", action="store_true", default=False, help="Don't capture command output")


# Get name and target from input args
def get_name_and_target(args):
    p_path = args.project.resolve()
    w_path = args.workspace.resolve() if args.workspace is not None else None
    if p_path == w_path:
        name = "<root>"
    else:
        name = str(p_path.relative_to(w_path)) if w_path is not None else p_path.name
    target = args.target.with_suffix("").name
    return (name, target)


# Run command and capture output
def capture_cmd(args, cmd, stamp=None):
    if args.verbose:
        # Just run command, don't capture output
        rc = subprocess.call(cmd)
    else:
        name, target = get_name_and_target(args)

        # Prepare output directory
        output: Path = args.output
        output.mkdir(parents=True, exist_ok=True)

        # Output files
        f_stamp = (stamp if stamp is not None else get_stamp()).replace(":", "_")
        out = output / f"{f_stamp}-{name}-{target}.out"
        err = output / f"{f_stamp}-{name}-{target}.err"

        # Run process and redirect outputs
        with out.open("w") as o, err.open("w") as e:
            o.write(f">>> Executing command: {' '.join(cmd)}\n")
            rc = subprocess.call(cmd, stdout=o, stderr=e)

    # Something went wrong?
    if rc != 0:
        pretty_print(get_stamp(), Icon.ERROR, name, target, Level.ERROR, f"!!! ERROR !!! -- see output in {out}")
        with err.open("r") as e:
            print(e.read())
        sys.exit(rc)
