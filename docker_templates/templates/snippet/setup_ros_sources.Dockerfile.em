@{
import os
import json
import urllib3

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
    apt_suffix = '2' if ros_version == 2 else ''
    source_suffix = 'latest'
    if 'testing_repo' in locals():
        if testing_repo:
            apt_suffix += '-testing'
            source_suffix = 'testing'
    repo_url = f'http://packages.ros.org/ros{apt_suffix}/ubuntu'

# Retrieve ros-apt-source packages version number
http = urllib3.PoolManager()
resp = http.request("GET", "https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest")
ros_apt_source_version = json.loads(resp.data)["tag_name"]
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
RUN curl -L -s -o /tmp/ros@(apt_suffix)-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/@(ros_apt_source_version)/ros@(apt_suffix)-apt-source_@(ros_apt_source_version).$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" \
    && apt-get update \
    && apt-get install /tmp/ros@(apt_suffix)-apt-source.deb \
    && rm -f /tmp/ros@(apt_suffix)-apt-source.deb
@[end if]@
