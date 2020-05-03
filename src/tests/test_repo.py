# Tests for repo helper
import logging
import os
import shutil
import subprocess
from argparse import Namespace

import pytest

from helpers.repo import RepoHandler, main
from tests.test_shared import TestHelpers


class TestRepoHelper(TestHelpers):
    @pytest.fixture
    def fake_repo(self, logs):
        self.build_repo("default")
        yield

    @pytest.fixture
    def fake_repo_other(self, logs):
        self.build_repo("other")
        yield

    @pytest.fixture
    def fake_repo_linked(self, logs):
        self.build_repo("linked")
        yield

    @pytest.fixture
    def repo_copy(self, logs):
        # Copy a repo sample in test folder
        self.build_repo("default")
        repo_copy = self.test_folder / "repo"
        shutil.copytree(self.repo, repo_copy)
        self.repo = repo_copy
        logging.debug(f"Copied test repo in {self.repo}")
        shutil.copytree(self.resources_folder / "workspace", self.test_folder / ".workspace")
        yield

    def build_repo(self, name):
        # Prepare a fake repo folder for tests
        self.repo = self.resources_folder / "repo" / name
        logging.debug(f"Use test repo in {self.repo}")

    def call_repo(self, args: list) -> str:
        # Call helper and catch output
        all_args = ["-r", str(self.repo)]
        all_args.extend(args)
        logging.debug(f"Calling repo main({', '.join(all_args)})")
        out = main(all_args)
        logging.debug(f"--> {out}")
        return out


class TestRepoHelperMisc(TestRepoHelper):
    def test_repo_no_action(self, fake_repo):
        # Test without action
        assert self.call_repo([]) == "No action specified"

    def test_branch_manifest(self, repo_copy):
        # Test to generate a branch manifest
        manifests = self.repo / "manifests"
        expected_branch = manifests / "branch.xml"
        assert not expected_branch.exists()
        assert self.call_repo(["-b", "--branch", "tools/fake"]) == f"Generated branch manifest: {expected_branch}"
        assert expected_branch.exists()

        # Verify updated branch
        r = RepoHandler(self.repo)
        found = False
        for p in r.projects:
            if r.project_name(p) == "tools":
                assert p.attributes["dest-branch"].value == "fake"
                assert p.attributes["revision"].value == "refs/heads/fake"
                found = True
        assert found

    def test_tag_manifest(self, repo_copy):
        # Test to generate a branch manifest with a tag
        manifests = self.repo / "manifests"
        expected_branch = manifests / "branch.xml"
        assert not expected_branch.exists()
        assert self.call_repo(["-b", "--tag", "tools/1.0"]) == f"Generated branch manifest: {expected_branch}"
        assert expected_branch.exists()

        # Verify updated branch
        r = RepoHandler(self.repo)
        found = False
        for p in r.projects:
            if r.project_name(p) == "tools":
                assert p.attributes["dest-branch"].value == "1.0"
                assert p.attributes["revision"].value == "refs/tags/1.0"
                found = True
        assert found

    def test_release_manifest_missing_tags(self, cd_project_api, monkeypatch):
        # Patch subprocess to fake the git call
        monkeypatch.setattr(subprocess, "check_output", lambda _, cwd: "".encode("utf-8"))

        # Generate a release manifest
        workspace = self.repo.parent.resolve() / ".workspace"
        try:
            self.call_repo(["--release-manifest", "-d", str(workspace / "deps.json")])
            raise AssertionError("Shouldn't get there")
        except RuntimeError as e:
            assert "No tags found for project api" in str(e)

    def test_release_manifest_ok(self, cd_project_api, monkeypatch):
        # Patch subprocess to fake the git call
        monkeypatch.setattr(subprocess, "check_output", lambda _, cwd: ("1.2\n2.3" if cwd.name == "api" else "4.5\n6.7").encode("utf-8"))

        # Generate a release manifest
        workspace = self.repo.parent.resolve() / ".workspace"
        expected_release = workspace / "tags" / "api" / "2.3.xml"
        assert not expected_release.exists()
        self.call_repo(["--release-manifest", "-d", str(workspace / "deps.json")]) == f"Generated release manifest: {expected_release}"
        assert expected_release.exists()

        # Verify updated branch
        r = RepoHandler(self.repo, other_manifest=expected_release)
        tested_projects = 0
        total_projects = 0
        for p in r.projects:
            assert "group" not in p.attributes
            total_projects += 1
            if r.project_name(p) == "workspace":
                assert p.attributes["dest-branch"].value == "api-2.3"
                assert p.attributes["revision"].value == "refs/tags/api-2.3"
                tested_projects += 1
            elif r.project_name(p) == "api":
                assert p.attributes["dest-branch"].value == "2.3"
                assert p.attributes["revision"].value == "refs/tags/2.3"
                tested_projects += 1
            elif r.project_name(p) in ["tools", "sample_dep"]:
                assert p.attributes["dest-branch"].value == "6.7"
                assert p.attributes["revision"].value == "refs/tags/6.7"
                tested_projects += 1
        assert tested_projects == 4
        assert total_projects == 4

    @pytest.fixture
    def cd_project_tools(self, repo_copy):
        initial_cwd = os.getcwd()
        p_dir = self.repo.parent / "tools"
        p_dir.mkdir(parents=True)
        os.chdir(str(p_dir))
        yield p_dir
        os.chdir(initial_cwd)

    @pytest.fixture
    def cd_project_api(self, repo_copy):
        initial_cwd = os.getcwd()

        # Create some projects directories
        (self.repo.parent / "tools").mkdir(parents=True)
        (self.repo.parent / "core" / "api").mkdir(parents=True)
        (self.repo.parent / "core" / "other").mkdir(parents=True)
        p_dir = self.repo.parent / "core" / "api"
        os.chdir(str(p_dir))
        yield p_dir
        os.chdir(initial_cwd)

    def register_git_args(self, args):
        # Just remember called args and fake a 0 rc
        self.git_args = args
        return 0

    def check_checkout(self, project_dir, branch, monkeypatch):
        # Create a branch manifest
        manifests = self.repo / "manifests"
        expected_branch = manifests / "branch.xml"
        assert self.call_repo(["-b", "--branch", "tools/fake"]) == f"Generated branch manifest: {expected_branch}"

        # Patch subprocess to fake the git call
        monkeypatch.setattr(subprocess, "check_call", self.register_git_args)

        # Checkout unknown project
        assert self.call_repo(["--checkout"]) == f"Branch {branch} checked out for project {project_dir.relative_to(self.repo.parent)}"
        assert len(self.git_args) == 3
        assert "git" in self.git_args
        assert "checkout" in self.git_args
        assert branch in self.git_args

    def test_checkout_tools(self, cd_project_tools, monkeypatch):
        # "tools" project checkout
        self.check_checkout(cd_project_tools, "fake", monkeypatch)

    def test_project_name_ok(self, cd_project_tools):
        # Verify name in normal project
        assert self.call_repo(["-n"]) == "tools"

    def test_project_path(self, cd_project_tools):
        # Verify path from name
        assert self.call_repo(["-p", "sample_dep"]) == "core/other"

    def test_deps_path(self, cd_project_api):
        # Verify dependencies paths
        workspace = self.repo.parent.resolve() / ".workspace"
        assert self.call_repo(["-p", "@deps", "-d", str(workspace / "deps.json")]) == "core/other\ntools"

    def test_dependencies(self, repo_copy):
        # Just test dependencies loading mechanisms
        r = RepoHandler(self.repo)
        args = Namespace(**{"dependencies": self.resources_folder / "workspace" / "deps.json"})
        deps = r.read_dependencies(args, "api")
        assert len(deps) == 2
        assert "tools" in deps
        assert "sample_dep" in deps
        deps = r.read_dependencies(args, "other")
        assert len(deps) == 1
        assert "tools" in deps


class RepoHelperSharedTests(TestRepoHelper):
    def test_groups(self):
        # Test groups command
        assert self.call_repo(["-g"]) == "core tools"

    def test_url(self):
        # Test url command
        assert self.call_repo(["-u"]) in ["git@github.com:dynod/devenv", "https://github.com/dynod/devenv"]

    def test_manifest(self):
        # Test manifest command
        assert self.call_repo(["-m"]) == self.expected_manifest()


@pytest.mark.usefixtures("fake_repo")
class TestStandardRepo(RepoHelperSharedTests):
    def expected_manifest(self) -> str:
        return "manifest.xml"


@pytest.mark.usefixtures("fake_repo_other")
class TestOtherRepo(RepoHelperSharedTests):
    def expected_manifest(self) -> str:
        return "other.xml"


@pytest.mark.usefixtures("fake_repo_linked")
class TestLinkedRepo(RepoHelperSharedTests):
    def expected_manifest(self) -> str:
        return "manifest.xml"
