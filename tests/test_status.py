# Tests for repo helper
import logging

from test_shared import TestHelpers  # isort:skip
from status import main, Level, Language, Icon  # isort:skip


class TestStatusHelper(TestHelpers):
    def run_status(self, args: list, icon: str = "build") -> int:
        # Update run ID
        self.update_run_id()

        # Run status with mandatory options
        all_args = [
            "--project",
            self.project,
            "--target",
            "dummy",
            "--status",
            "Dummy Status",
            "--icon",
            icon,
            "--output",
            str(self.run_folder),
        ]
        all_args.extend(args)
        logging.info(f"Calling command with args: {' '.join(all_args)}")
        return main(all_args)

    def test_workspace(self):
        logging.info("Try with project and workspace being the same")
        assert 0 == self.run_status(["--workspace", self.project])

    def test_levels(self):
        for level in Level:
            logging.info(f"Give a try with level '{level.value}'")
            assert 0 == self.run_status(["--level", level.value])

    def test_languages(self):
        for lang in Language:
            logging.info(f"Give a try with lang '{lang.value}'")
            assert 0 == self.run_status(["--lang", lang.value])

    def test_icons(self):
        for icon in Icon:
            logging.info(f"Give a try with icon '{icon.value}'")
            assert 0 == self.run_status([], icon=icon.value)

    def test_verbose_command(self):
        logging.info("Try with command in verbose mode (no logs)")
        assert 0 == self.run_status(["--verbose", "ls"])
        assert len(list(self.run_folder.glob("*"))) == 0

    def test_captured_command(self):
        logging.info("Try with command in normal mode (with logs)")
        assert 0 == self.run_status(["ls"])
        assert len(list(self.run_folder.glob("*-tests-dummy.*"))) == 2

    def test_error_command(self):
        logging.info("Try with error while running command")
        assert 100 == self.run_status(["apt", "install", "completely-unknown-package"])
        assert len(list(self.run_folder.glob("*-tests-dummy.*"))) == 2
