# Test make targets
import logging

from test_shared import TestHelpers

PHONY_PATTERN = ".PHONY:"


class TestMake(TestHelpers):
    def map_dynamic_targets(self, target: str) -> list:
        # Handle dynamic targets with some default values
        if target == "$(PYTHON_VENV)":
            return ["venv"]
        return [target]

    def list_targets(self) -> set:
        targets = set()

        # Check all rules definitions files
        for makefile in (self.get_root_folder() / "rules").glob("*.mk"):
            # Iterate on lines
            with makefile.open("r") as f:
                for line in f.readlines():
                    # Check all PHONY targets
                    if line.startswith(PHONY_PATTERN):
                        # Gather all targets
                        for target in filter(lambda x: len(x) > 0, line[len(PHONY_PATTERN) :].strip(" \n").split(" ")):
                            targets.update(self.map_dynamic_targets(target))

        logging.info("Founds PHONY targets: " + ", ".join(targets))
        return targets

    def test_targets(self):
        # Count phony targets (will have to be updated when makefile system is updated; just to be sure that make targets coverage is up to date)
        assert len(self.list_targets()) == 15
