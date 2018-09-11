#!/bin/bash
set -e

unset ROS_DISTRO
# setup ros1 environment
source "/opt/ros/$ROS1_DISTRO/setup.bash"

# setup ros2 environment
source "/opt/ros/$ROS2_DISTRO/setup.bash"

unset ROS1_DISTRO
unset ROS2_DISTRO

exec "$@"
