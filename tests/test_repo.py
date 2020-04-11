# Tests for repo helper
import logging
import os
import shutil
import subprocess

import pytest

from test_shared import TestHelpers  # isort:skip
from repo import main, RepoHandler  # isort:skip


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
                found = True
        assert found

    @pytest.fixture
    def cd_project_unknown(self, repo_copy):
        initial_cwd = os.getcwd()
        p_dir = self.repo.parent / "unknown"
        p_dir.mkdir(parents=True)
        os.chdir(str(p_dir))
        yield p_dir
        os.chdir(initial_cwd)

    @pytest.fixture
    def cd_project_tools(self, repo_copy):
        initial_cwd = os.getcwd()
        p_dir = self.repo.parent / "tools"
        p_dir.mkdir(parents=True)
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

    def test_checkout_unknown(self, cd_project_unknown, monkeypatch):
        # Unknown project checkout
        self.check_checkout(cd_project_unknown, "master", monkeypatch)

    def test_checkout_tools(self, cd_project_tools, monkeypatch):
        # "tools" project checkout
        self.check_checkout(cd_project_tools, "fake", monkeypatch)


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
