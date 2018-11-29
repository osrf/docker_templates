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

import hashlib
import re
import string
import urllib.request

# TODO: think of a better version pattern like
#  r'\d(?!Version\:\s)(.+)(?=(~\w+\n))' but works without a trailing ~
version_pattern = r'(?<= )\d+\.\d+\.\d+\-\d+'

packagePatternTemplateLookup = {
    'gazebo_packages':  string.Template(r'(\bPackage: gazebo$gazebo_version\n)(.*\n)'),
    'ros_packages':     string.Template(r'(\bPackage: ros-$rosdistro_name-$package\n)(.*\n)'),
    'ros2_packages':    string.Template(r'(\bPackage: ros-$ros2distro_name-$package\n)(.*\n)'),
}

indexUrlTemplateLookup = {
    'gazebo_packages':  string.Template('http://packages.osrfoundation.org/gazebo/$os_name-$release/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros_packages':     string.Template('http://packages.ros.org/$release/ubuntu/dists/$os_code_name/main/binary-$arch/Packages'),
    'ros2_packages':    string.Template('http://repo.ros2.org/$os_name/main/dists/$os_code_name/main/binary-$arch/Packages'),
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

packageInReleaseLookup = {
    'gazebo_packages':  string.Template('http://packages.osrfoundation.org/gazebo/$os_name-$release/dists/$os_code_name/InRelease'),
    'ros_packages':     string.Template('http://packages.ros.org/$release/ubuntu/dists/$os_code_name/InRelease'),
    'ros2_packages':    string.Template('http://repo.ros2.org/$os_name/main/dists/$os_code_name/InRelease'),
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
    package_pattern = re.compile(package_pattern_raw)

    return package_pattern

def getPackageVersion(data, package_pattern, package, package_index):
    """Use package index to get package version"""

    # Parse for version_number
    matchs = re.search(package_pattern, package_index)
    version_line = matchs.groups(0)[1] # Grab the second line of the first match
    package_version = re.search(version_pattern, version_line).group(0) # extract version_number

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

def getPackageReleaseToken(data, package_release_url):
    """Get package release token"""

    # Download package index
    req = urllib.request.Request(package_release_url)
    with urllib.request.urlopen(req) as response:
        package_release = response.read().decode('utf-8')
    token = {}
    token['date'] = re.search(r'Date: (.*)', package_release).group(1)
    token['digest'] = hashlib.sha256(package_release.encode('utf-8')).hexdigest()
    return token

def expandPackages(data):
    for package_type in indexUrlTemplateLookup:
        if package_type in data:
            package_index_url_template = indexUrlTemplateLookup[package_type]
            package_index_url = package_index_url_template.substitute(data)
            package_index = getPackageIndex(data, package_index_url)
            package_versions = getPackageVersions(data, package_index, data[package_type], package_type)
            data[package_type] = package_versions
            package_inrelease_url_template = packageInReleaseLookup[package_type]
            package_inrelease_url = package_inrelease_url_template.substitute(data)
            data[package_type + '_token'] = getPackageReleaseToken(data, package_inrelease_url)
