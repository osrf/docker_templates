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

import string
import re
import urllib.request

from docker_templates.eol_distro import isDistroEOL

# TODO: think of a better version pattern like
#  r'\d(?!Version\:\s)(.+)(?=(~\w+\n))' but works without a trailing ~
version_pattern = r'(?<=Version: )\d+\.\d+\.\d+\-\d+'

packagePatternTemplateLookup = {
    'gazebo_packages':  string.Template(r'(\bPackage: gazebo$gazebo_version\n)(.*?(?:\r*\n{2}))'),
    'ros_packages':     string.Template(r'(\bPackage: ros-$rosdistro_name-$package\n)(.*?(?:\r*\n{2}))'),
    'ros2_packages':    string.Template(r'(\bPackage: ros-$ros2distro_name-$package\n)(.*?(?:\r*\n{2}))'),
}

indexUrlTemplateLookup = {
    'gazebo_packages':  string.Template('http://packages.osrfoundation.org/gazebo/$os_name-$release/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros_packages':     string.Template('http://packages.ros.org/ros/ubuntu/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros2_packages':    string.Template('http://packages.ros.org/ros2/ubuntu/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros_packages_snapshots':    string.Template('http://snapshots.ros.org/$rosdistro_name/final/ubuntu/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros2_packages_snapshots':    string.Template('http://snapshots.ros.org/$ros2distro_name/final/ubuntu/dists/$os_code_name/main/binary-$arch/Packages'),
}

packageNameVersionTemplateLookup = {
    'gazebo_packages':  string.Template('$package=$package_version*'),
    'ros_packages':     string.Template('ros-$rosdistro_name-$package=$package_version*'),
    'ros2_packages':    string.Template('ros-$ros2distro_name-$package=$package_version*'),
}

packageNameTemplateLookup = {
    'gazebo_packages':  string.Template('$package'),
    'ros_packages':     string.Template('ros-$rosdistro_name-$package'),
    'ros2_packages':    string.Template('ros-$ros2distro_name-$package'),
}

def getPackageIndex(data, package_index_url):
    """Get current online package index"""

    # Download package index
    req = urllib.request.Request(package_index_url)
    with urllib.request.urlopen(req) as response:
        package_index = response.read().decode('utf-8')

    return package_index

def getPackagePattern(data, package_pattern_template, package):
    """Get package pattern"""

    package_pattern_raw = package_pattern_template.substitute(data,package=package)
    package_pattern = re.compile(package_pattern_raw, re.DOTALL)

    return package_pattern

def getPackageVersion(data, package_pattern, package, package_index):
    """Use package index to get package version"""

    # Parse for version_number
    matchs = re.search(package_pattern, package_index)
    package_info = matchs.group(0)
    package_version = re.search(version_pattern, package_info).group(0) # extract version_number

    return package_version

def getPackageVersions(data, package_index, packages, package_type):
    """Use package index to get package versions"""

    package_versions = []

    if data['version'] != False:
        for package in packages:

            # Determine package_pattern
            package_pattern_template = packagePatternTemplateLookup[package_type]
            package_pattern = getPackagePattern(data, package_pattern_template, package)

            # Determine package_version
            package_version = getPackageVersion(data, package_pattern, package, package_index)

            # Determine package_pattern
            package_name_template = packageNameVersionTemplateLookup[package_type]
            package_name = package_name_template.substitute(data, package=package, package_version=package_version)

            package_versions.append(package_name)

        return package_versions
    else:
        for package in packages:

            # Determine package_pattern
            package_name_template = packageNameTemplateLookup[package_type]
            package_name = package_name_template.substitute(data, package=package)

            package_versions.append(package_name)

        return package_versions

def expandPackages(data):
    for package_type in indexUrlTemplateLookup:
        if package_type in data:
            # determine if distro is eol and apply the appropriate index URL template
            ros_distro_name = ''
            if package_type == 'ros_packages':
                ros_distro_name = data['rosdistro_name']
            elif package_type == 'ros2_packages':
                ros_distro_name = data['ros2distro_name']
            eol = isDistroEOL(ros_distro_name, data['os_code_name'])
            if eol:
                package_index_url_template = indexUrlTemplateLookup[package_type + '_snapshots']
            else:
                package_index_url_template = indexUrlTemplateLookup[package_type]
            package_index_url = package_index_url_template.substitute(data)
            package_index = getPackageIndex(data, package_index_url)
            package_versions = getPackageVersions(data, package_index, data[package_type], package_type)
            data[package_type] = package_versions
