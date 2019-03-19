@{
if ros_version == '2':
    package_list = [
        'python3-colcon-common-extensions',
        'python3-rosdep',
        'python3-vcstool',
    ]
else:
    package_list = [
        'python-rosdep',
        'python-rosinstall',
        'python-vcstools',
    ]
}@
# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    @(' \\\n    '.join(sorted(package_list)))@  \
    && rm -rf /var/lib/apt/lists/*
