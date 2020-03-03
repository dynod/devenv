#!/usr/bin/env python3

# Helper script for repo handling

import sys
import re
import subprocess
from argparse import ArgumentParser
from xml.dom import minidom
from pathlib import Path


class RepoHandler:
    def __init__(self, root: Path):
        manifest_link = root / "manifest.xml"
        self.manifest_path = manifest_link.resolve()
        self.manifests_root = (root / "manifests").resolve()
        self.dom = minidom.parse(self.manifest_path.as_posix())

        # Resolve to real (included) manifest if not a link
        if not manifest_link.is_symlink():
            self.manifest_path = self.manifests_root / next(self.includes).attributes["name"].value
            self.dom = minidom.parse(self.manifest_path.as_posix())

    @property
    def manifest(self) -> minidom.Node:
        return next(filter(lambda n: n.nodeName == "manifest", self.dom.childNodes))

    @property
    def projects(self) -> minidom.NodeList:
        return filter(lambda n: n.nodeName == "project", self.manifest.childNodes)

    @property
    def includes(self) -> minidom.NodeList:
        return filter(lambda n: n.nodeName == "include", self.manifest.childNodes)

    def project_groups(self, project: minidom.Node) -> list:
        return project.attributes["groups"].value.split(",") if "groups" in project.attributes else []

    @property
    def groups(self) -> set:
        return {g for groups in map(self.project_groups, self.projects) for g in groups}

    def print_groups(self):
        # Get filtered groups (i.e. without the default/notdefault ones)
        print(" ".join(filter(lambda g: g not in ["default", "notdefault"], self.groups)))

    def print_url(self):
        # Get remote URL
        git_out = str(subprocess.check_output(["git", "remote", "-v"], cwd=self.manifests_root), encoding="utf-8")
        print(re.match(r"[^ ]+[ \t]+([^ ]+)[ \t]+[^ ]+", git_out.splitlines()[0]).group(1))

    def print_manifest(self):
        # Get manifest relative path
        print(self.manifest_path.relative_to(self.manifests_root).as_posix())


def main():
    # Parse args
    parser = ArgumentParser(description="Helper script for repo metadata")
    parser.add_argument("-r", "--root", type=Path, required=True, help="Path to repo root")
    actions = parser.add_mutually_exclusive_group()
    actions.add_argument("-g", "--groups", action="store_true", help="Display manifest available groups list")
    actions.add_argument("-u", "--url", action="store_true", help="Display manifest repository remote URL")
    actions.add_argument("-m", "--manifest", action="store_true", help="Display current manifest relative path")
    args = parser.parse_args(sys.argv[1:])

    # Prepare repo metadata reader
    repo_root = RepoHandler(args.root)

    # Handle actions
    actions = {}
    actions[args.groups] = repo_root.print_groups
    actions[args.url] = repo_root.print_url
    actions[args.manifest] = repo_root.print_manifest
    if True in actions:
        actions[True]()
    else:
        print("No action specified")

    # We're done
    sys.exit(0)


if __name__ == "__main__":
    main()
