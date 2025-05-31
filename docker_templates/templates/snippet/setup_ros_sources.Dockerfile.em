@{
import os

import rosdistro
index = rosdistro.get_index(rosdistro.get_index_url())
dist_info = index.distributions[ros_distro]
ros_version = int(dist_info['distribution_type'][-1])

from docker_templates.eol_distro import isDistroEOL

if isDistroEOL(ros_distro_status=dist_info['distribution_status'], os_distro_name=os_code_name):
    repo_url = os.path.join(
        'http://snapshots.ros.org',
        str(ros_distro),
        'final',
        str(os_name)
    )
    repo_key = '4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA'
    source_suffix = 'snapshots'
else:
    repo_key = 'C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654'
    apt_suffix = '2' if ros_version == 2 else ''
    source_suffix = 'latest'
    if 'testing_repo' in locals():
        if testing_repo:
            apt_suffix += '-testing'
            source_suffix = 'testing'
    repo_url = f'http://packages.ros.org/ros{apt_suffix}/ubuntu'
}@
# Setup ROS Apt sources
RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') ;\
    curl -L -s -o /tmp/ros@(ros_version)-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros@(ros_version)-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" &&\
    apt-get update && \
    apt-get install /tmp/ros@(ros_version)-apt-source.deb;
