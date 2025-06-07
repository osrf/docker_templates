@{
import distro
import hashlib
import os
import requests

import rosdistro
index = rosdistro.get_index(rosdistro.get_index_url())
dist_info = index.distributions[ros_distro]
ros_version = int(dist_info['distribution_type'][-1])

from docker_templates.eol_distro import isDistroEOL

is_distro_eol = isDistroEOL(ros_distro_status=dist_info['distribution_status'], os_distro_name=os_code_name)
if is_distro_eol:
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

    # Get the latest tag
    ros_apt_source_latest = requests.get('https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest')
    tag_name = ros_apt_source_latest.json().get('tag_name')

    # Get the latest version and compute the checksum
    fetch_url = f"https://github.com/ros-infrastructure/ros-apt-source/releases/download/{tag_name}/ros{apt_suffix}-apt-source_{tag_name}.{os_code_name}_all.deb"
    try:
        ros_apt_source_deb = requests.get(fetch_url)
        hashobj = hashlib.sha256(ros_apt_source_deb.content)
        file_256checksum = hashobj.hexdigest()
    except Exception as e:
        file_256checksum = f"ERROR Failed to compute checksum for {fetch_url} do not accept image. Exception: {e}"

    # Temp filename for simplicity of embedding
    temp_filename = f"/tmp/ros{apt_suffix}-apt-source.deb"
}@

@[if is_distro_eol]@
# setup keys
RUN set -eux; \
       key='@(repo_key)'; \
       export GNUPGHOME="$(mktemp -d)"; \
       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
       mkdir -p /usr/share/keyrings; \
       gpg --batch --export "$key" > /usr/share/keyrings/ros@(ros_version)-@(source_suffix)-archive-keyring.gpg; \
       gpgconf --kill all; \
       rm -rf "$GNUPGHOME"

# setup sources.list
RUN echo "deb [ signed-by=/usr/share/keyrings/ros@(ros_version)-@(source_suffix)-archive-keyring.gpg ] @(repo_url) @(os_code_name) main" > /etc/apt/sources.list.d/ros@(ros_version)-@(source_suffix).list
@[else]@
# Setup ROS Apt sources
RUN curl -L -s -o @(temp_filename) @(fetch_url) \
    && echo "@(file_256checksum) @(temp_filename)" | sha256sum --strict --check \
    && apt-get update \
    && apt-get install @(temp_filename) \
    && rm -f @(temp_filename) \
    && rm -rf /var/lib/apt/lists/*
@[end if]@
