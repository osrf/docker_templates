@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
))@
@(TEMPLATE(
    'snippet/from_base_image.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
    arch=arch,
    base_image=base_image,
    maintainer_name=maintainer_name,
))@
@(TEMPLATE(
    'snippet/setup_tzdata.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
))@
@{
template_dependencies = [
    'dirmngr',
    'gnupg2',
    'lsb-release',
    'wget',
]
# add 'python3-pip' to 'template_dependencies' if pip dependencies are declared
if 'pip3_install' in locals():
    if isinstance(pip3_install, list) and pip3_install != []:
        template_dependencies.append('python3-pip')
}@
@(TEMPLATE(
    'snippet/install_upstream_package_list.Dockerfile.em',
    packages=template_dependencies,
    upstream_packages=upstream_packages if 'upstream_packages' in locals() else [],
))@
@
# setup ros2 keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros2-latest.list

@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_version=ros_version,
))@

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

@[if 'pip3_install' in locals()]@
@[  if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[  end if]@
@[end if]@

# install ros2 packages
ENV ROS_DISTRO @ros2distro_name
RUN mkdir -p /opt/ros/$ROS_DISTRO
ARG ROS2_BINARY_URL=@ros2_binary_url
RUN wget -q $ROS2_BINARY_URL -O - | \
    tar -xj --strip-components=1 -C /opt/ros/$ROS_DISTRO

# install setup files
RUN apt-get update && apt-get install -q -y \
    ros-$ROS_DISTRO-ros-workspace \
    && rm -rf /var/lib/apt/lists/*

@[if 'rosdep_override' in locals()]@
# add custom rosdep rule files
@[  for rule_file in rosdep_override]@
COPY @rule_file /etc/ros/rosdep/
RUN echo "yaml file:///etc/ros/rosdep/@rule_file" | \
    cat - /etc/ros/rosdep/sources.list.d/20-default.list > temp && \
    mv temp /etc/ros/rosdep/sources.list.d/20-default.list
@[  end for]@
RUN rosdep update

@[end if]@
@
@[if 'rosdep' in locals()]@
@{
if 'path' not in rosdep:
  rosdep['path']='/opt/ros/$ROS_DISTRO/share'
}@
# install dependencies
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && apt-get update \
    && rosdep install -y \
    --from-paths @(rosdep['path']) \
    --ignore-src \
    --skip-keys " \
      @(' \\\n      '.join(rosdep['skip_keys']))@ " \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@
# FIXME Remove this once rosdep detects ROS 2 packages https://github.com/ros-infrastructure/rosdep/issues/660
# ignore installed rosdep keys
ENV ROS_PACKAGE_PATH /opt/ros/$ROS_DISTRO/share

@[if 'entrypoint_name' in locals()]@
@[  if entrypoint_name]@
@{
entrypoint_file = entrypoint_name.split('/')[-1]
}@
# setup entrypoint
COPY ./@entrypoint_file /

ENTRYPOINT ["/@entrypoint_file"]
@[  end if]@
@[end if]@
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
