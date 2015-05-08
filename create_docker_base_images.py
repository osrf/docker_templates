#!/usr/bin/env python3

import sys

from ros_buildfarm.templates import create_dockerfile
from ros_buildfarm.docker_common import DockerfileArgParser


def main(argv=sys.argv[1:]):
    # Create parser
    parser = DockerfileArgParser()
    # generate data for config
    data = parser.parse(argv)

    # Print parsed meta packages
    pkg_names = data['packages']
    print("Found the following packages:")
    for pkg_name in sorted(pkg_names):
        print('  -', pkg_name)

    # Print parsed template packages
    template_pkg_names = data['template_packages']
    print("Priority of template packages:")
    for template_pkg_name in template_pkg_names:
        print('  -', template_pkg_name)

    # template_name is specified relative to the templates folder in the template_packages
    template_name = 'docker_images/create_base_image.Dockerfile.em'
    dockerfile_dir = data['dockerfile_dir']

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir)

if __name__ == '__main__':
    main()
