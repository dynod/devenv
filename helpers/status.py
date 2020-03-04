#!/usr/bin/env python3

# Helper script for status printing
import sys
from argparse import ArgumentParser
from common import get_stamp, pretty_print, Icon, Level, add_common_args, get_name_and_target, capture_cmd


def main():
    # Parse args
    parser = ArgumentParser(description="Helper script for status printing")
    add_common_args(parser)
    parser.add_argument("-s", "--status", required=True, help="Status to be displayed")
    parser.add_argument("-l", "--level", type=Level, default=Level.INFO, help="Color level")
    parser.add_argument("-i", "--icon", type=Icon, required=True, help="Displayed emoji")
    args, cmd = parser.parse_known_args(sys.argv[1:])

    # Reckon project name and target
    name, target = get_name_and_target(args)

    # Get time
    stamp = get_stamp()

    # Print status
    pretty_print(stamp, args.icon, name, target, args.level, args.status)

    # Is there something to run?
    if len(cmd) > 0:
        capture_cmd(args, cmd, stamp)


if __name__ == "__main__":
    main()
