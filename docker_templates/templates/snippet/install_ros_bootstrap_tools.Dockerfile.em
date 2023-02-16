@{
import rosdistro
index = rosdistro.get_index(rosdistro.get_index_url())
dist_info = index.distributions[ros_distro]
# distribution_type is 'ros1' or 'ros2' we retrieve the ROS version number (1 or 2) as an int: https://www.ros.org/reps/rep-0153.html#index-file
ros_version = int(dist_info['distribution_type'][-1])
ros_python_version = dist_info['python_version']
prefix = 'python'
if ros_python_version == 3:
    prefix += str(ros_python_version)
package_list = [
    'build-essential',
    f'{prefix}-rosdep',
]
if ros_version == 2:
    package_list += [
        'git',
        f'{prefix}-colcon-common-extensions',
        f'{prefix}-colcon-mixin',
        f'{prefix}-vcstool',
    ]
else:
    package_list += [
        f'{prefix}-rosinstall',
        f'{prefix}-vcstools',
    ]
}@
# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    @(' \\\n    '.join(sorted(package_list)))@  \
    && rm -rf /var/lib/apt/lists/*
