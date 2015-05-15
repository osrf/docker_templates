#!/usr/bin/env python3

import argparse
import os
import pkg_resources
import sys
import yaml

from collections import OrderedDict
try:
    from cStringIO import StringIO
except ImportError:
    from io import StringIO
from em import Interpreter

from ros_buildfarm.templates import create_dockerfile
from ros_buildfarm.common import get_debian_package_name
from ros_buildfarm.docker_common import DockerfileArgParser


def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    """Load yaml data into an OrderedDict"""
    class OrderedLoader(Loader):
        pass

    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)


def main(argv=sys.argv[1:]):
    """Create Dockerfiles for images from platform and image yaml data"""

    # create the top-level parser
    parser = argparse.ArgumentParser(
        description="Generate the 'Dockerfile's for the base docker images")
    subparsers = parser.add_subparsers(
                                       help='help for subcommand',
                                       dest='subparser_name')

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

    args = parser.parse_args(argv)

    if args.subparser_name == 'explicit':
        platform_path = args.platform
        images_path = args.images
        output_path = args.output

    elif args.subparser_name == 'dir':
        platform_path = 'platform.yaml'
        images_path = 'images.yaml.em'
        platform_path = os.path.join(args.directory, platform_path)
        images_path = os.path.join(args.directory, images_path)
        output_path = args.directory

    # Ream platform perams
    with open(platform_path, 'r') as f:
        # use safe_load instead load
        platform = yaml.safe_load(f)['platform']

    # Ream image perams using platform perams
    images_yaml = StringIO()
    try:
        interpreter = Interpreter(output=images_yaml)
        interpreter.file(open(images_path, 'r'), locals=platform)
        images_yaml = images_yaml.getvalue()
    except Exception as e:
        print("Error processing %s" % images_path)
        raise
    finally:
        interpreter.shutdown()
        interpreter = None
    # Use ordered list
    images = ordered_load(images_yaml, yaml.SafeLoader)['images']

    # For each image tag
    for image in images:

        # Get data for image
        data = dict(images[image])
        data['tag_name'] = image

        # Add platform perams
        data.update(platform)

        # Get path to save Docker file
        dockerfile_dir = os.path.join(output_path, image)
        if not os.path.exists(dockerfile_dir):
            os.makedirs(dockerfile_dir)
        data['dockerfile_dir'] = dockerfile_dir

        # generate Dockerfile
        create_dockerfile(data)

if __name__ == '__main__':
    main()
