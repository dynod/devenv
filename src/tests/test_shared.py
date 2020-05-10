# Just a common class to define root folder
import logging
import shutil
from pathlib import Path

import pytest
from pytest_multilog import TestHelper


class TestHelpers(TestHelper):
    @property
    def run_folder(self) -> Path:
        return self.test_folder / ("out." + str(self.run_id))

    def update_run_id(self):
        if not hasattr(self, "run_id"):
            self.run_id = 1
        else:
            self.run_id += 1

    @property
    def project(self) -> str:
        return Path(__file__).parent.as_posix()

    @property
    def resources_folder(self) -> Path:
        return Path(__file__).parent / "resources"

    @pytest.fixture
    def repo_copy(self, logs):
        # Copy a repo sample in test folder
        self.build_repo("default")
        repo_copy = self.test_folder / ".repo"
        shutil.copytree(self.repo, repo_copy)
        self.repo = repo_copy
        logging.debug(f"Copied test repo in {self.repo}")
        shutil.copytree(self.resources_folder / "workspace", self.test_folder, dirs_exist_ok=True)
        yield

    def build_repo(self, name):
        # Prepare a fake repo folder for tests
        self.repo = self.resources_folder / "repo" / name
        logging.debug(f"Use test repo in {self.repo}")
