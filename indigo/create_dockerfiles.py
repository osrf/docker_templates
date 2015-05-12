#!/usr/bin/env python3

import sys
import pkg_resources

from ros_buildfarm.templates import create_dockerfile
from ros_buildfarm.docker_common import DockerfileArgParser


def main(argv=sys.argv[1:]):

    args = ['--template_packages', 'ros_docker_images',
            '--rosdistro-name', 'indigo',
            '--os-name', 'ubuntu',
            '--os-code-name', 'trusty',
            '--arch', 'amd64',
            '--dockerfile-dir', 'ros_core',
            '--packages', 'ros-indigo-ros-core']

    # Create parser
    parser = DockerfileArgParser()
    # generate data for config
    data = parser.parse(args)
    data['base_image'] = True

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
    template_name = 'docker_images/create_ros_core_image.Dockerfile.em'
    dockerfile_dir = data['dockerfile_dir']

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir)

    # template_name is specified relative to the templates folder in the template_packages
    template_name = 'docker_images/create_ros_base_image.Dockerfile.em'
    args = ['--template_packages', 'ros_docker_images',
            '--rosdistro-name', 'indigo',
            '--os-name', 'ubuntu',
            '--os-code-name', 'trusty',
            '--arch', 'amd64',
            '--dockerfile-dir', 'ros_base',
            '--packages', 'ros-indigo-ros-base']
    data = parser.parse(args)
    data['base_image'] = False
    data['base_name'] = 'ros'
    data['base_tag_name'] = data['rosdistro'] + '-' + 'ros-core'
    dockerfile_dir = data['dockerfile_dir']

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir)

    # template_name is specified relative to the templates folder in the template_packages
    template_name = 'docker_images/create_ros_base_image.Dockerfile.em'
    args = ['--template_packages', 'ros_docker_images',
            '--rosdistro-name', 'indigo',
            '--os-name', 'ubuntu',
            '--os-code-name', 'trusty',
            '--arch', 'amd64',
            '--dockerfile-dir', 'robot',
            '--packages', 'ros-indigo-robot']
    data = parser.parse(args)
    data['base_image'] = False
    data['base_name'] = 'ros'
    data['base_tag_name'] = data['rosdistro'] + '-' + 'ros-base'
    dockerfile_dir = data['dockerfile_dir']

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir)

    # template_name is specified relative to the templates folder in the template_packages
    template_name = 'docker_images/create_ros_base_image.Dockerfile.em'
    args = ['--template_packages', 'ros_docker_images',
            '--rosdistro-name', 'indigo',
            '--os-name', 'ubuntu',
            '--os-code-name', 'trusty',
            '--arch', 'amd64',
            '--dockerfile-dir', 'perception',
            '--packages', 'ros-indigo-perception']
    data = parser.parse(args)
    data['base_image'] = False
    data['base_name'] = 'ros'
    data['base_tag_name'] = data['rosdistro'] + '-' + 'ros-base'
    dockerfile_dir = data['dockerfile_dir']

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir)

if __name__ == '__main__':
    main()
