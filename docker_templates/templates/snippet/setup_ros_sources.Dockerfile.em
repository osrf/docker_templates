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
# setup keys
RUN set -eux; \
       key='@(repo_key)'; \
       export GNUPGHOME="$(mktemp -d)"; \
       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
       mkdir -p /etc/apt/keyrings; \
       gpg --batch --export "$key" > /usr/share/keyrings/ros@(ros_version)-@(source_suffix)-archive-keyring.gpg; \
       gpgconf --kill all; \
       rm -rf "$GNUPGHOME"

# setup sources.list
RUN echo "deb [ signed-by=/usr/share/keyrings/ros@(ros_version)-@(source_suffix)-archive-keyring.gpg ] @(repo_url) @(os_code_name) main" > /etc/apt/sources.list.d/ros@(ros_version)-@(source_suffix).list
