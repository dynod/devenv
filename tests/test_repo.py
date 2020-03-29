# Tests for repo helper
import logging

import pytest

from test_shared import TestHelpers  # isort:skip
from repo import main  # isort:skip


class TestRepoHelper(TestHelpers):
    @pytest.fixture
    def fake_repo(self, logs):
        yield self.build_repo("default")

    @pytest.fixture
    def fake_repo_other(self, logs):
        yield self.build_repo("other")

    @pytest.fixture
    def fake_repo_linked(self, logs):
        yield self.build_repo("linked")

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


@pytest.mark.usefixtures("fake_repo")
class TestRepoHelperMisc(TestRepoHelper):
    def test_repo_no_action(self):
        # Test without action
        assert self.call_repo([]) == "No action specified"


class RepoHelperSharedTests(TestRepoHelper):
    def test_groups(self):
        # Test groups command
        assert self.call_repo(["-g"]) == "core tools"

    def test_url(self):
        # Test url command
        assert self.call_repo(["-u"]) == "git@github.com:dynod/devenv"

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
