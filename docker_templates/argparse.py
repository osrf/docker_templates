#!/usr/bin/env python3

import yaml

from argparse import ArgumentParser


class DockerfileArgParser(ArgumentParser):
    """Argument parser class Dockerfile auto generation"""

    def set(self):
        """Setup parser for Dockerfile auto generation"""

        # create the top-level parser
        subparsers = self.add_subparsers(help='help for subcommand', dest='subparser_name')

        # create the parser for the "explicit" command
        parser_explicit = subparsers.add_parser(
            'explicit',
            help='explicit --help')
        parser_explicit.add_argument(
            '-p', '--platform',
            required=True,
            help="Path to platform config")
        parser_explicit.add_argument(
            '-i', '--images',
            required=True,
            help="Path to images config")
        parser_explicit.add_argument(
            '-o', '--output',
            required=True,
            help="Path to write generate Dockerfiles")

        # create the parser for the "dir" command
        parser_dir = subparsers.add_parser(
            'dir',
            help='dir --help')
        parser_dir.add_argument(
            '-d', '--directory',
            required=True,
            help="Path to read config and write output")
