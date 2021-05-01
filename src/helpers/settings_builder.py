#!/usr/bin/env python3

# Helper script to build settings files
import json
import os
import re
import subprocess
import sys
import traceback
from abc import ABC, abstractmethod
from argparse import ONE_OR_MORE, ArgumentParser
from configparser import ConfigParser
from pathlib import Path

# Pattern matching for output values
MAKE_VALUES_PATTERN = re.compile("@<@(.*?)@>@")


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
            # Prepare environment:
            # - remove ones coming from calling make instance
            # - set ones to configure vars display
            env = dict(os.environ)
            for make_var in list(filter(lambda n: n.startswith("MAKE") or n == "MFLAGS", env.keys())):
                del env[make_var]
            pattern_str = " ".join(patterns)
            env.update({"SUB_MAKE": "1", "DISPLAY_MAKEFILE_VAR": pattern_str, "WITH_VALUE_SEPARATORS": "1"})

            # Run make
            cp = subprocess.run(["make", "display"], env=env, stdout=subprocess.PIPE)
            if cp.returncode != 0:
                raise RuntimeError("Unexpected error while running make display for patterns: " + pattern_str)
            out = cp.stdout.decode("utf-8").rstrip("\n")

            # Process output
            values = []
            pos = 0
            while pos >= 0:
                m = MAKE_VALUES_PATTERN.search(out, pos)
                if m is not None:
                    values.append(m.group(1))
                    pos = m.end()
                else:
                    pos = -1

            # Replace in content
            cwd = Path(os.getcwd())
            for index in range(len(patterns)):
                value = values[index]

                # Replace some special characters
                value = value.replace("@CR", "\n")
                value = value.replace("@SP", " ")
                value = value.replace("@TB", "\t")

                # Handle paths
                p = Path(value)
                if p.is_absolute() and cwd in p.parents:
                    value = self.get_cwd_prefix() + str(p.relative_to(cwd))

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

    def get_cwd_prefix(self) -> str:
        # Prefix for current project folder in settings
        return ""


# Setting builder for setup.cfg
class SetupCfgSettingsBuilder(SettingsBuilder):
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


# Setting builder for VS Code settings.json
class SettingsJsonSettingsBuilder(SettingsBuilder):
    def build_layers(self):
        # Add to json model per layers
        model = {}
        for f_path in self.settings:
            if f_path.exists():
                with f_path.open("r") as f:
                    # Load new model fragment
                    m_fragment = json.load(f)

                # Iterate on new fragments items
                for k, v in m_fragment.items():
                    # Already exists in target model?
                    if k in model:
                        # List: extend
                        if isinstance(v, list):
                            model[k].extend(v)
                        # Map: update
                        elif isinstance(v, dict):
                            model[k].update(v)
                        # Otherwise: replace
                        else:
                            model[k] = v
                    else:
                        # New key
                        model[k] = v

        # Write to output file
        self.gen_file.parent.mkdir(parents=True, exist_ok=True)
        with self.gen_file.open("w") as f:
            json.dump(model, f, indent=4)

    def get_cwd_prefix(self) -> str:
        # Prefix for current project folder in settings
        return "${workspaceFolder}/"


# Resolution map
SETUP_CFG = "setup.cfg"
SETTINGS_JSON = "settings.json"
LAUNCH_JSON = "launch.json"
SETTING_BUILDERS_MAP = {SETUP_CFG: SetupCfgSettingsBuilder, SETTINGS_JSON: SettingsJsonSettingsBuilder, LAUNCH_JSON: SettingsJsonSettingsBuilder}


# Main function
def main(args: list) -> int:
    # Parse args
    parser = ArgumentParser(description="Helper script for settings files build")
    parser.add_argument("settings", nargs=ONE_OR_MORE, type=Path, help="Path to settings files to be merged")
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
        print(f"Error occurred: {e}\n" + "".join(traceback.format_tb(e.__traceback__)), file=sys.stderr, flush=True)
        rc = 1
    return rc


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main(sys.argv[1:]))
