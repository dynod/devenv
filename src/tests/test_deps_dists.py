import os
import subprocess
from pathlib import Path

import pytest

from tests.test_shared import TestHelpers


# Test "list-deps-dists.sh" helper
@pytest.mark.usefixtures("repo_copy")
class TestDepsDistsHelper(TestHelpers):
    @property
    def test_project(self) -> Path:
        return self.test_folder / "core" / "other"

    def call_helper(self) -> str:
        os.environ["DEVENV_ROOT"] = self.root_folder.as_posix()
        r = subprocess.check_output([str(self.root_folder / "helpers" / "list-deps-dists.sh"), str(self.test_project)]).decode().rstrip("\n")
        del os.environ["DEVENV_ROOT"]
        return r

    def test_not_built_no_url(self):
        # Local deps neither built nor provided through an internal URL
        assert self.call_helper() == ""

    def test_built(self):
        # Local dep with built dist present in output folder
        out = self.test_project / "out" / "artifacts" / "python"
        out.mkdir(parents=True)
        artifact = out / "foo-stuff-1.2.3.tar.gz"
        artifact.touch()
        os.environ["OUTPUT_ROOT"] = (self.test_project / "out").as_posix()
        assert self.call_helper() == artifact.resolve().as_posix()
        del os.environ["OUTPUT_ROOT"]

    def test_repo(self):
        # Local dep not built, but internal repo provided
        os.environ["PYTHON_INTERNAL_REPOSITORY_URL"] = "http://foo.org/artifacts"
        assert self.call_helper() == "http://foo.org/artifacts/foo-stuff-1.2.3.tar.gz"
        del os.environ["PYTHON_INTERNAL_REPOSITORY_URL"]
