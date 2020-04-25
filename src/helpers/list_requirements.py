#!/usr/bin/env python3

# Helper to build a setup.cfg-compatible requirements list

import sys
from pathlib import Path


def main(args: list) -> str:
    # Read requirements from provided file
    out = ""
    with Path(args[0]).open("r") as f:
        for req in filter(lambda x: not x.startswith("#") and not len(x) == 0, map(lambda y: y.rstrip(" \n"), f.readlines())):
            out += ("@CR@TB" if len(out) > 0 else "") + req
    return out


if __name__ == "__main__":  # pragma: no cover
    print(main(sys.argv[1:]))
    sys.exit(0)
