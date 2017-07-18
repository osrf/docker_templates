# Copyright 2015-2016 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
