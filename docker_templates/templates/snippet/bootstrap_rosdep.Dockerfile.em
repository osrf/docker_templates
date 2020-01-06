@{
rosdep_update_args = []
from docker_templates.eol_distro import isDistroEOL
if int(ros_version) == 2:
    ros_distro_name = ros2distro_name
elif int(ros_version) == 1:
    ros_distro_name = rosdistro_name

if isDistroEOL(ros_distro_name=ros_distro_name):
    rosdep_update_args.append('--include-eol-distros')
rosdep_update_args.extend(['--rosdistro', ros_distro_name])
}@
# bootstrap rosdep
RUN rosdep init \
    && rosdep update@('' if rosdep_update_args == [] else ' ' + ' \\\n    '.join(rosdep_update_args))@

