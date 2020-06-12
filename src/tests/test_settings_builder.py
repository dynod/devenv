# Tests for repo helper
import json
import logging
import subprocess
from configparser import ConfigParser
from pathlib import Path

from helpers.settings_builder import SETTINGS_JSON, SETUP_CFG, main
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
    def templates(self) -> Path:
        return self.root_folder / "templates" / "python"


class TestUnknownFormat(TestSettingsBuilderHelper):
    def test_unknown_output_file(self):
        # Unknown settings file
        assert self.run_builder("unknown") == 1


class TestSetupCfgBuilder(TestSettingsBuilderHelper):
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
        return self.templates / "setup-test.cfg"

    @property
    def setup_resources(self):
        return self.resources_folder / "setup"

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

    def test_setup_unknown_pattern(self, monkeypatch):
        # Test with file containing an unknown pattern, and fake make return
        monkeypatch.setattr(subprocess, "run", lambda _, env, stdout: FakeCP(0))
        assert self.run_builder(SETUP_CFG, [self.setup_resources / "unknown_pattern.cfg"]) == 1

    def test_setup_make_error(self, monkeypatch):
        # Test with file containing an unknown pattern, and fake make RC
        monkeypatch.setattr(subprocess, "run", lambda _, env, stdout: FakeCP(1))
        assert self.run_builder(SETUP_CFG, [self.setup_resources / "unknown_pattern.cfg"]) == 1


class TestSettingsJsonBuilder(TestSettingsBuilderHelper):
    @property
    def devenv_settings(self):
        return self.root_folder / ".devenv" / "vscode" / "shared" / "settings.json"

    @property
    def built_json_model(self):
        with (self.run_folder / SETTINGS_JSON).open("r") as f:
            return json.load(f)

    @property
    def devenv_json_model(self):
        with (self.devenv_settings).open("r") as f:
            return json.load(f)

    @property
    def settings_resources(self):
        return self.resources_folder / "settings"

    def check_model(self, expected: list):
        model = self.built_json_model
        assert len(expected) == len(model), f"Bad model items count: {', '.join(model.keys())}"
        assert all(s in model for s in expected), f"Missing sections: {', '.join(model.keys())}"

    def test_settings_json_missing(self):
        # Test with one file
        assert self.run_builder(SETTINGS_JSON, [self.templates / "unknown.json"]) == 0
        assert not len(self.built_json_model)

    def test_settings_json_1file(self):
        # Test with one file
        assert self.run_builder(SETTINGS_JSON, [self.devenv_settings]) == 0
        expected_keys = []
        expected_keys.extend(self.devenv_json_model.keys())
        self.check_model(expected_keys)
        assert "pytest" in self.built_json_model["cSpell.words"]

    def test_settings_json_merge_lists(self):
        # Merge two files with the same list
        assert self.run_builder(SETTINGS_JSON, [self.devenv_settings, self.settings_resources / "list_merge.json"]) == 0
        expected_keys = ["other_key"]
        expected_keys.extend(self.devenv_json_model.keys())
        self.check_model(expected_keys)
        assert "pytest" in self.built_json_model["cSpell.words"]
        assert "other1" in self.built_json_model["cSpell.words"]
        assert self.built_json_model["other_key"]

    def test_settings_json_merge_maps(self):
        # Merge two files with the same map
        assert self.run_builder(SETTINGS_JSON, [self.settings_resources / "map1.json", self.settings_resources / "map2.json"]) == 0
        self.check_model(["testMap"])
        assert "value1" in self.built_json_model["testMap"]
        assert "value2" in self.built_json_model["testMap"]

    def test_settings_json_merge_other(self):
        # Merge files with the same list and boolean item
        assert (
            self.run_builder(SETTINGS_JSON, [self.devenv_settings, self.settings_resources / "list_merge.json", self.settings_resources / "bool_merge.json"])
            == 0
        )
        expected_keys = ["other_key"]
        expected_keys.extend(self.devenv_json_model.keys())
        self.check_model(expected_keys)
        assert not self.built_json_model["other_key"]
