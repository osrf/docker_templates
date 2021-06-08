@{
import os

from docker_templates.eol_distro import isDistroEOL
if int(ros_version) == 2:
    ros_distro_name = ros2distro_name
elif int(ros_version) == 1:
    ros_distro_name = rosdistro_name

if isDistroEOL(ros_distro_name=ros_distro_name, os_distro_name=os_code_name):
    repo_url = os.path.join(
        'http://snapshots.ros.org',
        str(ros_distro_name),
        'final',
        str(os_name)
    )
    repo_key = '4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA'
    source_suffix = 'snapshots'
else:
    repo_key = 'C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654'
    apt_suffix = ''
    source_suffix = 'latest'
    if 'testing_repo' in locals():
        if testing_repo:
            apt_suffix = '-testing'
            source_suffix = 'testing'

    if int(ros_version) == 1:
        repo_url = f'http://packages.ros.org/ros{apt_suffix}/ubuntu'
    elif int(ros_version) == 2:
        repo_url = f'http://packages.ros.org/ros2{apt_suffix}/ubuntu'
}@
# setup sources.list
RUN echo "deb @(repo_url) @(os_code_name) main" > /etc/apt/sources.list.d/ros@(ros_version)-@(source_suffix).list

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys @(repo_key)
