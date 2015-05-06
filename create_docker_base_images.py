#!/usr/bin/env python3

import argparse
import os
import pkg_resources
import sys

from catkin_pkg.packages import find_packages
from ros_buildfarm.argument import \
    add_argument_distribution_repository_key_files
from ros_buildfarm.argument import add_argument_distribution_repository_urls
from ros_buildfarm.argument import add_argument_dockerfile_dir
from ros_buildfarm.common import get_binary_package_versions
from ros_buildfarm.common import get_debian_package_name
from ros_buildfarm.common import get_distribution_repository_keys
from ros_buildfarm.common import get_user_id
from ros_buildfarm.templates import create_dockerfile


def main(argv=sys.argv[1:]):
    parser = argparse.ArgumentParser(
        description="Generate the 'Dockerfile's for the base docker images")
    parser.add_argument(
        '--rosdistro-name',
        required=True,
        help='The name of the ROS distro to identify the setup file to be '
             'sourced')
    parser.add_argument(
        '--packages',
        nargs='+',
        help='What (meta)packages to include in the image.')
    parser.add_argument(
       '--template_packages',
       nargs='+',
       help='What packages to use for template.')
    parser.add_argument(
        '--os-name',
        required=True,
        help="The OS name (e.g. 'ubuntu')")
    parser.add_argument(
        '--os-code-name',
        required=True,
        help="The OS code name (e.g. 'trusty')")
    parser.add_argument(
        '--arch',
        required=True,
        help="The architecture (e.g. 'amd64')")
    add_argument_distribution_repository_urls(parser)
    add_argument_distribution_repository_key_files(parser)
    add_argument_dockerfile_dir(parser)
    args = parser.parse_args(argv)
    print("argv",argv)

    pkg_names = args.packages
    print("Found the following packages:")
    for pkg_name in sorted(pkg_names):
        print('  -', pkg_name)

    template_pkg_names = args.template_packages
    print("Priority of template packages:")
    for template_pkg_name in template_pkg_names:
        print('  -', template_pkg_name)


    # generate Dockerfile
    data = {
        'os_name': args.os_name,
        'os_code_name': args.os_code_name,
        'arch': args.arch,

        'distribution_repository_urls': args.distribution_repository_urls,
        'distribution_repository_keys': get_distribution_repository_keys(
            args.distribution_repository_urls,
            args.distribution_repository_key_files),

        'packages': pkg_names,
        'rosdistro': args.rosdistro_name,

        'template_packages': template_pkg_names,

    }
    template_name = 'docker_images/create_base_image.Dockerfile.em'
    create_dockerfile(template_name, data, args.dockerfile_dir)


if __name__ == '__main__':
    main()
