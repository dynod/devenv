# Tests for repo helper
import logging
import subprocess
from configparser import ConfigParser
from pathlib import Path

from helpers.settings_builder import SETUP_CFG, main
from tests.test_shared import TestHelpers

UNKNOWN = [Path("/tmp/not/existing/file.ext")]


class FakeCP:
    def __init__(self, rc):
        self.returncode = rc
        self.stdout = "".encode("utf-8")


class TestSettingsBuilderHelper(TestHelpers):
    def run_builder(self, o: Path, s: list = UNKNOWN) -> int:
        # Update run ID
        self.update_run_id()

        # Run status with mandatory options
        all_args = ["--output", str(self.run_folder / o)]
        all_args.extend(map(lambda x: str(x), s))
        logging.info(f"Calling command with args: {' '.join(all_args)}")
        return main(all_args)

    @property
    def built_setup(self) -> ConfigParser:
        c = ConfigParser()
        with (self.run_folder / SETUP_CFG).open("r") as f:
            c.read_file(f.readlines())
        return c

    @property
    def setup_cfg_sections(self) -> list:
        return self.built_setup.sections()

    @property
    def devenv_setup(self):
        return self.get_root_folder() / "templates" / "setup-test.cfg"

    @property
    def setup_resources(self):
        return self.resources_folder / "setup"

    def test_unknown_output_file(self):
        # Unknown settings file
        assert self.run_builder("unknown") == 1

    def test_setup_cfg_no_file(self):
        # Test without input file
        assert self.run_builder(SETUP_CFG) == 0
        assert len(self.setup_cfg_sections) == 0

    def check_sections(self, expected: list):
        sections = self.setup_cfg_sections
        assert len(expected) == len(sections), f"Bad sections count: {', '.join(sections)}"
        assert all(s in sections for s in expected), f"Missing sections: {', '.join(sections)}"

    def test_setup_cfg_1file(self):
        # Test with one file
        assert self.run_builder(SETUP_CFG, [self.devenv_setup]) == 0
        self.check_sections(["run", "tool:pytest"])
        assert self.built_setup.get("tool:pytest", "testpaths") == "src/tests"

    def test_setup_cfg_2files(self):
        # Test with two files, without conflict
        assert self.run_builder(SETUP_CFG, [self.devenv_setup, self.setup_resources / "workspace.cfg"]) == 0
        self.check_sections(["run", "tool:pytest", "dummy"])
        assert self.built_setup.get("dummy", "foo") == "bar"
        assert self.built_setup.get("dummy", "other") == "1,2,3"

    def test_setup_cfg_3files(self):
        # Test with three files, with merged sections
        assert self.run_builder(SETUP_CFG, [self.devenv_setup, self.setup_resources / "workspace.cfg", self.setup_resources / "project.cfg"]) == 0
        self.check_sections(["run", "tool:pytest", "dummy"])
        assert self.built_setup.get("dummy", "foo") == "other"
        assert self.built_setup.get("dummy", "other") == "1,2,3"

    def test_setup_unknown_pattern(self):
        # Test with file containing an unknown pattern
        assert self.run_builder(SETUP_CFG, [self.setup_resources / "unknown_pattern.cfg"]) == 1

    def test_setup_make_error(self, monkeypatch):
        # Test with file containing an unknown pattern, and fake make RC
        monkeypatch.setattr(subprocess, "run", lambda _, env, stdout: FakeCP(1))
        assert self.run_builder(SETUP_CFG, [self.setup_resources / "unknown_pattern.cfg"]) == 1
