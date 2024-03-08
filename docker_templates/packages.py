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

import gzip
import string
import re
import urllib.request
# import json

import rosdistro

from docker_templates.eol_distro import isDistroEOL

_cached_package_indexs = {}

DockerToAptArchLookup = {
    'amd64': 'amd64',
    'arm32v7':'armhf',
    'arm64v8':'arm64',
    'i386':'i386'
}

version_pattern = r'(?<=Version: ).*\n'

sha256_pattern = r'(?<=SHA256: )[0-9a-f]{64}'

packagePatternTemplateLookup = {
    'gazebo_packages':  string.Template(r'(\bPackage: $package\n)(.*?(?:\r*\n{2}))'),
    'ros_packages':     string.Template(r'(\bPackage: ros-$rosdistro_name-$package\n)(.*?(?:\r*\n{2}))'),
    'ros2_packages':    string.Template(r'(\bPackage: ros-$ros2distro_name-$package\n)(.*?(?:\r*\n{2}))'),
}

indexUrlTemplateLookup = {
    'gazebo_packages':  string.Template('http://packages.osrfoundation.org/gazebo/$os_name-$release/dists/$os_code_name/main/binary-$arch/Packages.gz'),
    'ros_packages':     string.Template('http://packages.ros.org/ros/ubuntu/dists/$os_code_name/main/binary-$arch/Packages.gz'),
    'ros2_packages':    string.Template('http://packages.ros.org/ros2/ubuntu/dists/$os_code_name/main/binary-$arch/Packages.gz'),
    'ros_packages_snapshots':    string.Template('http://snapshots.ros.org/$rosdistro_name/final/$os_name/dists/$os_code_name/main/binary-$arch/Packages.gz'),
    'ros2_packages_snapshots':    string.Template('http://snapshots.ros.org/$ros2distro_name/final/$os_name/dists/$os_code_name/main/binary-$arch/Packages.gz'),
}

packageVersionTemplateLookup = {
    'gazebo_packages':  string.Template('=$package_version'),
    'ros_packages':     string.Template('=$package_version'),
    'ros2_packages':    string.Template('=$package_version'),
}

packageNameTemplateLookup = {
    'gazebo_packages':  string.Template('$package'),
    'ros_packages':     string.Template('ros-$rosdistro_name-$package'),
    'ros2_packages':    string.Template('ros-$ros2distro_name-$package'),
}

def getPackageIndex(data, package_index_url):
    """Get current online package index"""

    global _cached_package_indexs
    if package_index_url in _cached_package_indexs:
        package_index = _cached_package_indexs[package_index_url]
    else:
        # Download package index
        req = urllib.request.Request(package_index_url)
        with urllib.request.urlopen(req) as response:
            package_index = gzip.decompress(response.read()).decode('utf-8')
        _cached_package_indexs[package_index_url] = package_index

    return package_index

def getPackagePattern(data, package_pattern_template, package):
    """Get package pattern"""

    package_pattern_raw = package_pattern_template.substitute(data,package=package)
    package_pattern = re.compile(package_pattern_raw, re.DOTALL)

    return package_pattern

def getPackageInfo(package_pattern, package_index):
    """Use package index to get package info"""

    # Parse for package info
    matchs = re.search(package_pattern, package_index)
    if matchs is None:
        return None
    package_info = matchs.group(0)

    return package_info

def getPackageSHA256(package_info):
    """Use package info to get package sha256"""

    # Parse for SHA56
    package_sha256 = re.search(sha256_pattern, package_info).group(0) # extract sha256

    return package_sha256

def getPackageVersion(package_info):
    """Use package info to get package version"""

    # Parse for version_number
    package_version = re.search(version_pattern, package_info).group(0) # extract version_number

    return package_version

def getPackageVersions(data, package_index, packages, package_type):
    """Use package index to get package versions"""

    package_versions = []

    # Determine package_pattern
    package_pattern_template = packagePatternTemplateLookup[package_type]
    package_name_template = packageNameTemplateLookup[package_type]
    package_version_template = packageVersionTemplateLookup[package_type]

    for package in packages:
        package_pattern = getPackagePattern(data, package_pattern_template, package)
        package_name = package_name_template.substitute(data, package=package)
        package_info = getPackageInfo(package_pattern, package_index)
        if package_info is None:
            continue
        package_sha256 = getPackageSHA256(package_info)

        if data['version'] != False:
            version = getPackageVersion(package_info)
            package_version = package_version_template.substitute(data, package_version=version)
        else:        
            package_version=''

        package_versions.append(dict(name=package_name, version=package_version, sha256=package_sha256))

    return package_versions

def expandPackages(data):
    # print("################################################################")
    # print(json.dumps(data,sort_keys=True, indent=4))
    # print("################################################################")
    data["archs"] = {i: dict() for i in data["archs"]}
    for package_type in indexUrlTemplateLookup:
        if package_type in data:
            # determine if distro is eol and apply the appropriate index URL template
            ros_distro_name = ""
            if package_type == "ros_packages":
                ros_distro_name = data["rosdistro_name"]
            elif package_type == "ros2_packages":
                ros_distro_name = data["ros2distro_name"]
            if ros_distro_name != "":
                index = rosdistro.get_index(rosdistro.get_index_url())
                dist_info = index.distributions[ros_distro_name]
                eol = isDistroEOL(
                    ros_distro_status=dist_info["distribution_status"],
                    os_distro_name=data["os_code_name"],
                )
            else:
                eol = isDistroEOL(
                    ros_distro_status=None,
                    os_distro_name=data["os_code_name"],
                )
            if eol:
                package_index_url_template = indexUrlTemplateLookup[package_type + '_snapshots']
            else:
                package_index_url_template = indexUrlTemplateLookup[package_type]
            for arch in data['archs']:
                data['arch'] = DockerToAptArchLookup[arch]
                package_index_url = package_index_url_template.substitute(data)
                package_index = getPackageIndex(data, package_index_url)
                package_versions = getPackageVersions(data, package_index, data[package_type], package_type)
                data['archs'][arch][package_type] = package_versions
