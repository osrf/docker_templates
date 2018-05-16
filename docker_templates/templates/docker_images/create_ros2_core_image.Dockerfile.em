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

# setup ros1 keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu @os_code_name main" > /etc/apt/sources.list.d/ros-latest.list

# setup ros2 keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://repo.ros2.org/@os_name/main @os_code_name main" > /etc/apt/sources.list.d/ros2-latest.list

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
@[if 'rosdistro_name' in locals()]@
@[  if rosdistro_name]@
ENV ROS_DISTRO @rosdistro_name
@[  end if]@
@[end if]@
ENV ROS2_DISTRO @ros2distro_name

@[if 'packages' in locals()]@
@[  if packages]@
# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
@[if 'pip3_install' in locals()]@
@[  if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[  end if]@
@[end if]@

@[if 'ros_packages' in locals()]@
@[  if ros_packages]@
# install ros packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros_packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
@[if 'ros2_packages' in locals()]@
@[  if ros2_packages]@
# install ros2 packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros2_packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
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
