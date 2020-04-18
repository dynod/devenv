#!/usr/bin/env python3

# Helper script for repo handling
import os
import re
import subprocess
import sys
from argparse import ArgumentParser, Namespace
from pathlib import Path
from xml.dom import minidom


class RepoHandler:
    def __init__(self, root: Path):
        self.repo_root = root
        self.main_manifest_path = self.repo_root / "manifest.xml"
        self.main_dom = minidom.parse(self.main_manifest_path.as_posix())
        self.manifest_path = self.main_manifest_path.resolve()
        self.manifests_root = (self.repo_root / "manifests").resolve()
        self.dom = minidom.parse(self.manifest_path.as_posix())

        # Resolve to real (included) manifest if not a link
        if not self.main_manifest_path.is_symlink():
            self.manifest_path = self.manifests_root / next(self.main_includes).attributes["name"].value
            self.dom = minidom.parse(self.manifest_path.as_posix())

    @property
    def main_manifest(self) -> minidom.Node:
        return next(filter(lambda n: n.nodeName == "manifest", self.main_dom.childNodes))

    @property
    def main_includes(self) -> minidom.NodeList:
        return filter(lambda n: n.nodeName == "include", self.main_manifest.childNodes)

    @property
    def manifest(self) -> minidom.Node:
        return next(filter(lambda n: n.nodeName == "manifest", self.dom.childNodes))

    @property
    def projects(self) -> minidom.NodeList:
        return filter(lambda n: n.nodeName == "project", self.manifest.childNodes)

    def project_attribute(self, project: minidom.Node, name: str) -> str:
        return project.attributes[name].value if name in project.attributes else ""

    def project_groups(self, project: minidom.Node) -> list:
        return self.project_attribute(project, "groups").split(",")

    def project_name(self, project: minidom.Node) -> str:
        return self.project_attribute(project, "name")

    def project_path(self, project: minidom.Node) -> str:
        return self.project_attribute(project, "path")

    def project_branch(self, project: minidom.Node) -> str:
        return self.project_attribute(project, "dest-branch")

    @property
    def groups(self) -> set:
        return {g for groups in map(self.project_groups, self.projects) for g in groups}

    def print_groups(self, args: Namespace):
        # Get filtered groups (i.e. without the default/notdefault ones)
        return " ".join(sorted(filter(lambda g: g not in ["default", "notdefault"], self.groups)))

    def print_url(self, args: Namespace):
        # Get remote URL
        git_out = str(subprocess.check_output(["git", "remote", "-v"], cwd=self.manifests_root), encoding="utf-8")
        return re.match(r"[^ ]+[ \t]+([^ ]+)[ \t]+[^ ]+", git_out.splitlines()[0]).group(1)

    def print_manifest(self, args: Namespace):
        # Get manifest relative path
        return self.manifest_path.relative_to(self.manifests_root).as_posix()

    def generate_branch_manifest(self, args: Namespace):
        # Build branch manifest

        # Iterate on configurations
        for project, branch in map(lambda x: (x[0], x[1]), map(lambda y: y.split("/"), args.branch)):
            # Iterate on matching projects
            for manifest_project in filter(lambda p: self.project_name(p) == project, self.projects):
                # Update branch
                manifest_project.attributes["dest-branch"] = branch
                manifest_project.attributes["revision"] = f"refs/heads/{branch}"

        # Serialize updated manifest
        branch_manifest = self.manifest_path.parent / "branch.xml"
        with branch_manifest.open("w") as f:
            f.write(self.dom.toxml())

        # Update main manifest included manifest, to point to the "branch" one
        include_node = next(self.main_includes)
        include_node.attributes["name"] = "branch.xml"
        with self.main_manifest_path.open("w") as f:
            f.write(self.main_dom.toxml())

        return f"Generated branch manifest: {branch_manifest}"

    def checkout_project(self, args: Namespace):
        # Guess project path from PWD + repo root
        relative_project_path = Path(os.getcwd()).relative_to(self.repo_root.resolve().parent).as_posix()
        matching_projects = list(filter(lambda p: self.project_path(p) == relative_project_path, self.projects))
        if len(matching_projects) == 1:
            branch = self.project_branch(matching_projects[0])
        else:
            # Strange case where project path is not found...
            # Well, consider using master...
            print(f"Unknown project path: {relative_project_path}, use master branch")
            branch = "master"

        # Checkout project
        subprocess.check_call(["git", "checkout", branch])
        return f"Branch {branch} checked out for project {relative_project_path}"


def main(args):
    # Parse args
    parser = ArgumentParser(description="Helper script for repo metadata")
    parser.add_argument("-r", "--root", type=Path, required=True, help="Path to repo root")
    actions = parser.add_mutually_exclusive_group()
    actions.add_argument("-g", "--groups", action="store_true", help="Display manifest available groups list")
    actions.add_argument("-u", "--url", action="store_true", help="Display manifest repository remote URL")
    actions.add_argument("-m", "--manifest", action="store_true", help="Display current manifest relative path")
    actions.add_argument("-b", "--branch-manifest", action="store_true", help="Generate a branch manifest for required project/branch (--branch)")
    actions.add_argument("-c", "--checkout", action="store_true", help="Checkout current project branch")
    parser.add_argument("--branch", metavar="PROJECT/BRANCH", default=[], action="append", help="Add a configuration to be part of branch manifest generation")
    args = parser.parse_args(args)

    # Prepare repo metadata reader
    repo_root = RepoHandler(args.root)

    # Handle actions
    actions = {}
    actions[args.groups] = repo_root.print_groups
    actions[args.url] = repo_root.print_url
    actions[args.manifest] = repo_root.print_manifest
    actions[args.branch_manifest] = repo_root.generate_branch_manifest
    actions[args.checkout] = repo_root.checkout_project
    if True in actions:
        return actions[True](args)
    else:
        return "No action specified"


if __name__ == "__main__":  # pragma: no cover
    print(main(sys.argv[1:]))
    sys.exit(0)
