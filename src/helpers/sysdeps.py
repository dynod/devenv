#!/usr/bin/env python3

import json
import shutil
import subprocess

# Helper script for system dependencies handling
import sys
from abc import ABC, abstractmethod
from argparse import ONE_OR_MORE, ArgumentParser, Namespace
from pathlib import Path
from typing import List, Set

if __name__ == "__main__":  # pragma: no cover
    # Hack for standalone invocation
    SRC = Path(__file__).parent.parent
    sys.path.insert(0, str(SRC))

from helpers.common import Icon, Level, add_common_args, capture_cmd, get_name_and_target, get_stamp, pretty_print, prompt_user  # noqa: E402 isort:skip


class Resolver(ABC):
    def __init__(self, name):
        self.name = name

    def resolve_package_names(self, args: Namespace, requirements: Set[str]) -> Set[str]:
        # Load and merge maps (json files from --database paths list)
        sys_deps_map = {}
        for database_path in args.database:
            with database_path.open("r") as f:
                sys_deps_map.update(json.load(f))

        # Resolve package names
        out = set()
        for requirement in requirements:
            assert requirement in sys_deps_map, f"Don't know how to resolve missing system dependency '{requirement}'"
            assert self.name in sys_deps_map[requirement], f"Don't know how to resolve missing system dependency '{requirement}' for '{self.name}' tool"
            out.add(sys_deps_map[requirement][self.name])

        return out

    def build_requirements(self, args: Namespace) -> set:
        requirements = set()
        for p in args.requirements:
            # Loop on valid (i.e. neither empty nor commented) lines
            with p.open("r") as f:
                for req in filter(lambda l: len(l) > 0 and not l.startswith("#"), f.readlines()):
                    requirements.add(req.strip(" \n").rstrip(" \n"))

        return requirements

    def is_missing(self, requirement: str) -> bool:
        req_path = Path(requirement)
        if req_path.is_absolute():
            # Absolute path: just check for existence
            return not req_path.exists()

        # Otherwise assume this is a command name: check on path
        return shutil.which(requirement) is None

    def resolve(self, args: Namespace) -> int:
        all_requirements = self.build_requirements(args)
        requirements = filter(self.is_missing, all_requirements) if not args.reinstall else all_requirements
        packages = self.resolve_package_names(args, requirements)
        if len(packages) > 0:
            # Delegate to package manager only if there is something to install
            return self.resolve_packages(args, packages)

        # Nothing to resolve
        return 0

    def resolve_packages(self, args: Namespace, packages: Set[str]):
        # Build command lines
        commands = self.get_install_commands(packages)

        # Add sudo if not root (see `id -u`)
        uid = subprocess.run(["id", "-u"], check=True, stdout=subprocess.PIPE).stdout.decode("utf-8").rstrip("\n")
        if uid != "0":
            for cmd in commands:
                cmd.insert(0, "sudo")

        # Reckon project name and target
        name, target = get_name_and_target(args)

        # Something to display?
        pretty_print(get_stamp(), Icon.FLOPPY, name, target, Level.INFO, "Some packages need to be installed: " + " ".join(packages))
        if not args.yes:
            # Print commands before running them
            print("\nThese commands will be executed:")
            for cmd in commands:
                print("   " + " ".join(cmd))

            # Prompt before running
            if not prompt_user("Ready to go"):
                # Install refused
                raise AssertionError("Install cancelled")

            print("")

        # Run commands
        pretty_print(get_stamp(), Icon.FLOPPY, name, target, Level.INFO, "Installing system dependencies")

        # Prepare sudo if needed
        if uid != "0":
            rc = subprocess.call(["sudo", "true"])
            if rc != 0:
                return rc

        for cmd in commands:
            # Ok to run
            pretty_print(get_stamp(), Icon.FLOPPY, name, target, Level.INFO, " >>> " + " ".join(cmd))
            rc = capture_cmd(args, cmd)
            if rc != 0:
                return rc

        # All went OK!
        return 0

    @abstractmethod
    def get_install_commands(self, packages: Set[str]) -> List[List[str]]:  # pragma: no cover
        pass


class AptResolver(Resolver):
    def __init__(self):
        super().__init__("apt")

    def get_install_commands(self, packages: Set[str]) -> List[List[str]]:
        # Resolve dependencies with apt install
        out = []

        # Build command lines
        cmd_update = ["apt", "update"]
        out.append(cmd_update)
        cmd_install = ["apt", "install", "-y"]
        cmd_install.extend(packages)
        out.append(cmd_install)

        return out


def get_resolver() -> Resolver:
    # Detect resolver according to available package management system
    if shutil.which("apt") is not None:
        return AptResolver()
    raise NotImplementedError("Unable to find a packaging tool for the current system")


def main(input_args: list):
    # Small parser
    parser = ArgumentParser(description="Helper script to check system dependencies")
    add_common_args(parser)
    parser.add_argument("-y", "--yes", action="store_true", default=False, help="Answer yes to asked questions")
    parser.add_argument("-r", "--reinstall", action="store_true", default=False, help="Don't check if package is already installed")
    parser.add_argument("-d", "--database", action="append", type=Path, required=True, help="Path to database file")
    parser.add_argument("requirements", nargs=ONE_OR_MORE, type=Path, help="List of system requirement files")
    args = parser.parse_args(input_args)

    # Build requirements list from provided files
    # ... and filter the missing ones
    # ... then let the resolver doing its job
    try:
        rc = get_resolver().resolve(args)
    except Exception as e:
        name, target = get_name_and_target(args)
        pretty_print(get_stamp(), Icon.ERROR, name, target, Level.ERROR, str(e))
        rc = 1
    return rc


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main(sys.argv[1:]))
