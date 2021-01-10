#!/usr/bin/env python3

# Helper script for repo handling
import json
import os
import re
import subprocess
import sys
from argparse import ArgumentParser, Namespace
from pathlib import Path
from xml.dom import minidom


class RepoHandler:
    def __init__(self, root: Path, other_manifest: Path = None):
        self.repo_root = root
        self.manifests_root = (self.repo_root / "manifests").resolve()

        # Default: deduce manifest from path
        if other_manifest is None:
            self.main_manifest_path = self.repo_root / "manifest.xml"
            self.main_dom = minidom.parse(self.main_manifest_path.as_posix())
            self.manifest_path = self.main_manifest_path.resolve()
            self.dom = minidom.parse(self.manifest_path.as_posix())

            # Resolve to real (included) manifest if not a link
            if not self.main_manifest_path.is_symlink():
                self.manifest_path = self.manifests_root / next(self.main_includes).attributes["name"].value
        else:
            # Use specified manifest
            self.manifest_path = other_manifest

        # Final DOM load
        self.dom = minidom.parse(self.manifest_path.as_posix())

    @property
    def workspace_root(self) -> Path:
        return self.repo_root.resolve().parent

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

    def project_by_name(self, name: str) -> minidom.Node:
        return next(filter(lambda p: self.project_name(p) == name, self.projects))

    def project_by_path(self, path: str) -> minidom.Node:
        try:
            return next(filter(lambda p: self.project_path(p) == path, self.projects))
        except StopIteration:  # pragma: no cover
            return None

    @property
    def groups(self) -> set:
        return {g for groups in map(self.project_groups, self.projects) for g in groups}

    @property
    def current_project_path(self) -> str:
        return Path(os.getcwd()).relative_to(self.workspace_root).as_posix()

    @property
    def current_project_name(self) -> str:
        p = self.current_project
        return self.project_name(p) if p is not None else ""

    @property
    def current_project(self) -> minidom.Node:
        current_path = self.current_project_path
        return self.project_by_path(current_path) if str(current_path) != "." else None

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

    def print_name(self, args: Namespace):
        # Get project name for current path
        return self.current_project_name

    def print_path(self, args: Namespace):
        # Check mode:
        if args.path == "@deps" and args.dependencies is not None:
            # Get all paths for current project dependencies
            out = ""
            for dep in self.read_dependencies(args, self.current_project_name):
                out += ("\n" if len(out) else "") + self.project_path(self.project_by_name(dep))
            return out

        # Get project path for required name
        return self.project_path(self.project_by_name(args.path))

    def generate_branch_manifest(self, args: Namespace):
        # Build branch manifest

        # Iterate on configurations
        for project, branch in map(lambda x: (x[0], x[1]), map(lambda y: y.split("/"), args.branch)):
            # Iterate on matching projects
            for manifest_project in filter(lambda p: self.project_name(p) == project, self.projects):
                # Update branch
                manifest_project.attributes["dest-branch"] = branch
                manifest_project.attributes["revision"] = f"refs/heads/{branch}"
        for project, tag in map(lambda x: (x[0], x[1]), map(lambda y: y.split("/"), args.tag)):
            # Iterate on matching projects
            for manifest_project in filter(lambda p: self.project_name(p) == project, self.projects):
                # Update tag
                manifest_project.attributes["dest-branch"] = tag
                manifest_project.attributes["revision"] = f"refs/tags/{tag}"

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

    def tag_pad(self, tag: str, max_pad: int = 3):
        # Pad with zeroes tag segments
        out = ""
        for segment in tag.split("."):
            if len(segment) > max_pad:
                raise RuntimeError(f'Tag segment "{segment}" is longer than configured max ({max_pad})')
            if len(out):
                out += "."
            pad_len = max_pad - len(segment)
            out += ("0" * pad_len) + segment
        return out

    def project_last_tag(self, project):
        # Get latest tag for this project
        tags = str(subprocess.check_output(["git", "tag", "-l"], cwd=self.workspace_root / Path(self.project_path(project))), encoding="utf-8").splitlines()
        if len(tags) == 0:
            raise RuntimeError(f"No tags found for project {self.project_name(project)}")
        tags.sort(key=self.tag_pad)
        return tags[len(tags) - 1]

    def generate_release_manifest(self, args: Namespace):
        # Build release manifest

        # Get project dependencies
        current_n = self.current_project_name
        deps = self.read_dependencies(args, current_n)
        deps.extend(["workspace", "devenv"])  # Everything depends on workspace and devenv

        # Get current project last tag
        last_tag = self.project_last_tag(self.current_project)

        # Will create workspace tag
        workspace_tag = current_n + "-" + last_tag

        # Iterate on all manifest projects
        to_remove = []
        for project in self.projects:
            n = self.project_name(project)
            if n == current_n or n in deps:
                # Current project or dependency: need to be part of the manifest

                # Check if current revision is not already a tag (or if current project is the workspace one)
                is_workspace = n == "workspace"
                if ("revision" not in project.attributes) or (not project.attributes["revision"].value.startswith("refs/tags/")) or is_workspace:
                    # Update tag
                    tag = workspace_tag if is_workspace else self.project_last_tag(project)
                    project.attributes["dest-branch"] = tag
                    project.attributes["revision"] = f"refs/tags/{tag}"
                    project.removeAttribute("groups")
            else:
                # Shall be removed from the release manifest: nothing to do with this project
                to_remove.append(project)

        # Remove useless projects from release manifest
        for p in to_remove:
            self.manifest.removeChild(p)

        # Serialize updated manifest
        workspace_project = self.workspace_root / Path(self.project_path(self.project_by_name("workspace")))
        release_manifest_name = f"tags/{current_n}/{last_tag}.xml"
        release_manifest = workspace_project / release_manifest_name
        release_manifest.parent.mkdir(parents=True, exist_ok=True)
        with release_manifest.open("w") as f:
            f.write(self.dom.toxml())

        # Commit & tag
        subprocess.check_call(["git", "add", release_manifest_name], cwd=workspace_project)
        subprocess.check_call(["git", "commit", "-m", f"Add release manifest for {current_n} {last_tag}"], cwd=workspace_project)
        subprocess.check_call(["git", "tag", workspace_tag, "master"], cwd=workspace_project)

        return f"Generated release manifest: {release_manifest}"

    def checkout_project(self, args: Namespace):
        # Guess project path from PWD + repo root
        branch = self.project_branch(self.current_project)

        # Checkout project
        subprocess.check_call(["git", "checkout", branch])
        return f"Branch {branch} checked out for project {self.current_project_name}"

    # Reads dependencies list for a given project
    def read_dependencies(self, args, name: str) -> list:
        # Load dependencies map from file
        with args.dependencies.open("r") as f:
            deps_map = json.load(f)

        # Return the one for current project + all shared ones
        out = set()
        for item in ["_shared", name]:
            if item in deps_map:
                for item_dep in deps_map[item]:
                    if item_dep != name:
                        out.add(item_dep)
        return sorted(out)


def main(args):
    # Parse args
    parser = ArgumentParser(description="Helper script for repo metadata")
    parser.add_argument("-r", "--root", type=Path, required=True, help="Path to repo root")
    actions = parser.add_mutually_exclusive_group()
    actions.add_argument("-g", "--groups", action="store_true", help="Display manifest available groups list")
    actions.add_argument("-u", "--url", action="store_true", help="Display manifest repository remote URL")
    actions.add_argument("-n", "--name", action="store_true", help="Display project name on repository")
    actions.add_argument("-m", "--manifest", action="store_true", help="Display current manifest relative path")
    actions.add_argument(
        "-b", "--branch-manifest", action="store_true", help="Generate a branch manifest for required project/branch (--branch) or tag (--tag)"
    )
    actions.add_argument("--release-manifest", action="store_true", help="Generate a release manifest for current project latest tag")
    actions.add_argument("-c", "--checkout", action="store_true", help="Checkout current project branch")
    actions.add_argument("-p", "--path", metavar="NAME", help="Display path for project NAME")
    parser.add_argument("--branch", metavar="PROJECT/BRANCH", default=[], action="append", help="Add a branch configuration to be part of manifest generation")
    parser.add_argument("--tag", metavar="PROJECT/TAG", default=[], action="append", help="Add a tag configuration to be part of manifest generation")
    parser.add_argument("-d", "--dependencies", type=Path, help="Workspace dependencies map file")
    args = parser.parse_args(args)

    # Prepare repo metadata reader
    repo_root = RepoHandler(args.root)

    # Handle actions
    actions = {}
    actions[args.groups] = repo_root.print_groups
    actions[args.url] = repo_root.print_url
    actions[args.manifest] = repo_root.print_manifest
    actions[args.name] = repo_root.print_name
    actions[args.branch_manifest] = repo_root.generate_branch_manifest
    actions[args.release_manifest] = repo_root.generate_release_manifest
    actions[args.checkout] = repo_root.checkout_project
    actions[args.path is not None] = repo_root.print_path
    if True in actions:
        return actions[True](args)
    else:
        return "No action specified"


if __name__ == "__main__":  # pragma: no cover
    print(main(sys.argv[1:]))
    sys.exit(0)
