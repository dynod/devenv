# Tests for sys deps helper
import builtins
import logging
import shutil
import subprocess

from test_shared import TestHelpers  # isort:skip
from sysdeps import main  # isort:skip


class TestStatusHelper(TestHelpers):
    def run_sysdeps(self, args: list) -> int:
        # Update run ID
        self.update_run_id()

        # Run status with mandatory options
        all_args = [
            "--project",
            self.project,
            "--target",
            "dummy",
            "--output",
            str(self.run_folder),
        ]
        all_args.extend(args)
        logging.info(f"Calling command with args: {' '.join(all_args)}")
        return main(all_args)

    def stub_file(self, file: str) -> str:
        return str(self.resources_folder / "sysdeps" / file)

    def test_missing_package_manager(self, monkeypatch):
        # Monkey patch for "which", to fake missing apt
        monkeypatch.setattr(shutil, "which", lambda _: None)

        # Should fail because don't know how to resolve packages
        assert 1 == self.run_sysdeps(["-d", "missing.json", "noreqs.txt"])

    def test_missing_files(self):
        # Should fail because provided files don't exist
        assert 1 == self.run_sysdeps(["-d", "missing.json", "noreqs.txt"])
        assert 1 == self.run_sysdeps(["-d", "missing.json", self.stub_file("existing_path.txt")])

    def test_already_installed_path(self):
        # Dry-run, with path already installed
        assert 0 == self.run_sysdeps(["-d", self.stub_file("empty.json"), self.stub_file("existing_path.txt")])

    def test_already_installed_command(self):
        # Dry-run, with command already installed
        assert 0 == self.run_sysdeps(["-d", self.stub_file("empty.json"), self.stub_file("existing_command.txt")])

    def test_missing_req_unresolvable_name(self):
        # Missing stuff, but don't know how to resolve it (package name is not present)
        assert 1 == self.run_sysdeps(["-d", self.stub_file("empty.json"), self.stub_file("missing_command.txt")])

    def test_missing_req_unresolvable_packager(self):
        # Missing stuff, but don't know how to resolve it (no instructions for current packaging system)
        assert 1 == self.run_sysdeps(["-d", self.stub_file("unknown_cmd.json"), self.stub_file("missing_command.txt")])

    def test_refused_install(self, monkeypatch):
        # Patch input to answer no
        monkeypatch.setattr(builtins, "input", lambda _: "N")

        # Missing stuff, and go to prompt, but refuse
        assert 1 == self.run_sysdeps(["-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])

    def record_commands(self, cmd):
        if not hasattr(self, "recorded_commands"):
            self.recorded_commands = []
        self.recorded_commands.append(" ".join(cmd))
        return 0

    def test_forced_install_user(self, monkeypatch):
        # Patch:
        # - subprocess.call to catch calls commands
        # - input to answer default
        monkeypatch.setattr(subprocess, "call", self.record_commands)
        monkeypatch.setattr(builtins, "input", lambda _: "")

        # Go to install, and check invoked commands
        assert 0 == self.run_sysdeps(["-v", "-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])
        assert len(self.recorded_commands) == 3
        assert "sudo true" in self.recorded_commands
        assert "sudo apt update" in self.recorded_commands
        assert "sudo apt install -y unknownpackage" in self.recorded_commands

    def test_prompt_install_user(self, monkeypatch):
        # Patch: subprocess.call to catch calls commands
        monkeypatch.setattr(subprocess, "call", self.record_commands)

        # Go to install, and check invoked commands
        assert 0 == self.run_sysdeps(["--yes", "-v", "-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])
        assert len(self.recorded_commands) == 3
        assert "sudo true" in self.recorded_commands
        assert "sudo apt update" in self.recorded_commands
        assert "sudo apt install -y unknownpackage" in self.recorded_commands

    def fake_uid_0(self, cmd, check, stdout):
        # Assume this is "id -u" call
        class OutputBean:
            def __init__(self, out):
                self.stdout = out

        return OutputBean("0".encode("utf-8"))

    def test_install_root(self, monkeypatch):
        # Patch:
        # - subprocess.call to catch calls commands
        # - subprocess.run to fake uid to 0
        monkeypatch.setattr(subprocess, "call", self.record_commands)
        monkeypatch.setattr(subprocess, "run", self.fake_uid_0)

        # Go to install, and check invoked commands
        assert 0 == self.run_sysdeps(["--yes", "-v", "-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])
        assert len(self.recorded_commands) == 2
        assert "apt update" in self.recorded_commands
        assert "apt install -y unknownpackage" in self.recorded_commands

    def test_failed_sudo(self, monkeypatch):
        # Patch subprocess.call to make "sudo true" call failling
        monkeypatch.setattr(subprocess, "call", lambda _: 1)

        # Go to install, but fail because of failed "sudo true"
        assert 1 == self.run_sysdeps(["--yes", "-v", "-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])

    def test_failed_install_root(self, monkeypatch):
        # Patch:
        # - subprocess.call to make calls failling
        # - subprocess.run to fake uid to 0
        monkeypatch.setattr(subprocess, "call", lambda _: 1)
        monkeypatch.setattr(subprocess, "run", self.fake_uid_0)

        # Go to install, and check invoked commands
        assert 1 == self.run_sysdeps(["--yes", "-v", "-d", self.stub_file("fake_package.json"), self.stub_file("missing_command.txt")])
