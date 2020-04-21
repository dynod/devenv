#!/usr/bin/env python3

# Helper script to build settings files

import os
import re
import subprocess
import sys
from abc import ABC, abstractmethod
from argparse import ONE_OR_MORE, ArgumentParser
from configparser import ConfigParser
from pathlib import Path


# Abstract API for settings builders
class SettingsBuilder(ABC):
    def __init__(self, settings: list, gen_file: Path):
        self.settings = settings
        self.gen_file = gen_file

    @abstractmethod
    def build_layers(self):  # pragma: no cover
        pass

    def build(self):
        # First build layers
        self.build_layers()

        # Read back the file
        with self.gen_file.open("r") as f:
            content = f.read()

        # Some patterns to replace?
        patterns = self.list_vars(content)
        if len(patterns) > 0:
            # Get values from makefile
            pattern_str = " ".join(patterns)
            cp = subprocess.run(["make", "display"], env={"SUB_MAKE": "1", "DISPLAY_MAKEFILE_VAR": pattern_str}, stdout=subprocess.PIPE)
            if cp.returncode != 0:
                raise RuntimeError("Unexpected error while running make display for patterns: " + pattern_str)
            out = cp.stdout.decode("utf-8").rstrip("\n")
            values = out.split(" ")
            if len(patterns) != len(values):
                raise RuntimeError(f"Unexpected mismatch between values ({out}) and patterns ({pattern_str})")

            # Replace in content
            cwd = Path(os.getcwd())
            for index in range(len(patterns)):
                # Handle paths
                value = values[index]
                p = Path(value)
                if p.is_absolute() and cwd in p.parents:
                    value = str(p.relative_to(cwd))

                # Process
                content = content.replace("{{" + patterns[index] + "}}", value)

            # Write updated content
            with self.gen_file.open("w") as f:
                f.write(content)

    def list_vars(self, content: str):
        # Look for variables patterns in the content
        out = set()
        p = re.compile("\\{\\{([A-Z0-9_]+)\\}\\}")
        m = p.search(content)
        while m is not None:
            out.add(m.group(1))
            m = p.search(content, m.end())
        return list(out)


# Setting builder for setup.cfg
class SetupCfgSettingBuilder(SettingsBuilder):
    def build_layers(self):
        # Load files per layers
        c = ConfigParser()
        for f_path in self.settings:
            if f_path.exists():
                with f_path.open("r") as f:
                    c.read_file(f.readlines())

        # Write to output file
        self.gen_file.parent.mkdir(parents=True, exist_ok=True)
        with self.gen_file.open("w") as f:
            c.write(f)


# Resolution map
SETUP_CFG = "setup.cfg"
SETTING_BUILDERS_MAP = {SETUP_CFG: SetupCfgSettingBuilder}


# Main function
def main(args: list) -> int:
    # Parse args
    parser = ArgumentParser(description="Helper script for settings files build")
    parser.add_argument("settings", nargs=ONE_OR_MORE, type=Path, help="Path settings to be merged")
    parser.add_argument("-o", "--output", type=Path, required=True, help="Path to output settings file")
    args = parser.parse_args(args)

    rc = 0
    try:
        # Get settings handler for output file name
        file_name = args.output.name
        if file_name not in SETTING_BUILDERS_MAP:
            raise NotImplementedError(f"Don't know how to build '{file_name}' settings file")

        # Ready to build
        SETTING_BUILDERS_MAP[file_name](args.settings, args.output).build()
    except Exception as e:
        print(str(e))
        rc = 1
    return rc


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main(sys.argv[1:]))
