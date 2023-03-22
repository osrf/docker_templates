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

import os
import pkg_resources
import shutil

import ros_buildfarm.templates
from ros_buildfarm.templates import create_dockerfile
from ros_buildfarm.templates import get_template_path
from ros_buildfarm.templates import expand_template, get_wrapper_scripts

from docker_templates.packages import indexUrlTemplateLookup

default_template_prefix_path = ros_buildfarm.templates.template_prefix_path

def expand_template_prefix_path(template_packages):
    # reset template_prefix_path
    ros_buildfarm.templates.template_prefix_path = default_template_prefix_path

    # expand template_prefix_path in order of preference
    for template_package in reversed(template_packages):
        template_package_path = pkg_resources.resource_filename(
            template_package, 'templates')
        ros_buildfarm.templates.template_prefix_path.insert(
            0, template_package_path)

def create_files(data, verbose=False):
    template_name = data['template_name']
    dockerfile_dir = data['dockerfile_dir']

    if 'template_packages' in data:
        expand_template_prefix_path(data['template_packages'])

    # generate Dockerfile
    create_dockerfile(template_name, data, dockerfile_dir, verbose)

    create_lockfiles(data)

    if 'entrypoint_name' in data:
        create_entrypoint(data)

def create_lockfiles(data):
    dockerfile_dir = data['dockerfile_dir']
    for arch_name, arch_data in data['archs'].items():
        for package_type, package_list in arch_data.items():
            lockfile_dir = os.path.join(dockerfile_dir, package_type)
            if not os.path.exists(lockfile_dir):
                os.makedirs(lockfile_dir)
            lockfile_path = os.path.join(lockfile_dir, arch_name + '.txt')
            if package_list:
                with open(lockfile_path, 'w') as h:
                    for package in package_list:
                        line = f"{package['name']}{package['version']}"
                        h.write(line)

def create_entrypoint(data):
    # find entrypoint path
    entrypoint_name = data['entrypoint_name']
    dockerfile_dir = data['dockerfile_dir']
    entrypoint_file = os.path.basename(entrypoint_name)
    entrypoint_dir = os.path.dirname(get_template_path(entrypoint_name))
    entrypoint_path = os.path.join(entrypoint_dir, entrypoint_file)

    # copy script into dockerfile_dir
    entrypoint_dest = os.path.join(dockerfile_dir, entrypoint_file)
    shutil.copyfile(entrypoint_path, entrypoint_dest)
    os.chmod(entrypoint_dest, 0o744)

def create_dockerlibrary(template_name, data, dockerlibrary_path, verbose=False):
    data['template_name'] = template_name
    data['wrapper_scripts'] = get_wrapper_scripts()
    content = expand_template(template_name, data)
    if verbose:
        for line in content.splitlines():
            print(' ', line)
    with open(dockerlibrary_path, 'w') as h:
        h.write(content)
