@{
if int(ros_version) == 2:
    package_list = [
        'build-essential',
        'git',
        'python3-colcon-common-extensions',
        'python3-colcon-mixin',
        'python3-rosdep',
        'python3-vcstool',
    ]
else:
    package_list = [
        'build-essential',
        'python-rosdep',
        'python-rosinstall',
        'python-vcstools',
    ]
}@
# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    @(' \\\n    '.join(sorted(package_list)))@  \
    && rm -rf /var/lib/apt/lists/*
