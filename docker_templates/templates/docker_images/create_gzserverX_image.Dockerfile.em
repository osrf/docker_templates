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
    'software-properties-common',
]
}@
@(TEMPLATE(
    'snippet/install_upstream_package_list.Dockerfile.em',
    packages=template_dependencies,
    upstream_packages=upstream_packages if 'upstream_packages' in locals() else [],
))@

RUN apt-add-repository ppa:libccd-debs \
    && apt-add-repository ppa:fcl-debs \
    && apt-add-repository ppa:dartsim

@[if 'ros_packages' in locals()]@
@[  if ros_packages]@
# ROS Setup ####################################################################
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

ENV ROS_DISTRO=@rosdistro_name
@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_version='1',
))@

# setup environment
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

@(TEMPLATE(
    'snippet/label_and_install_package_list.Dockerfile.em',
    group='ros',
    packages=ros_packages,
))@
@[  end if]@
@[end if]@

@[if 'gazebo_packages' in locals()]@
@[if gazebo_packages]@
# Gazebo Setup #################################################################
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN . /etc/os-release \
    && echo "deb http://packages.osrfoundation.org/gazebo/$ID-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-latest.list

@(TEMPLATE(
    'snippet/label_and_install_package_list.Dockerfile.em',
    group='gazebo',
    packages=gazebo_packages,
))@
@[end if]@
@[end if]@

@[if 'packages' in locals()]@
@[if packages]@
# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*
@[end if]@
@[end if]@

@[if 'pip_install' in locals()]@
@[if pip_install]@
# install python packages
RUN pip install \
    @(' \\\n    '.join(pip_install))@

@[end if]@
@[end if]@

@[if 'sources' in locals()]@
@[if sources]@
# clone source
RUN mkdir -p @(ws)/src
@(TEMPLATE(
    'snippet/clone_sources.Dockerfile.em',
    sources=sources,
    ws=ws,
))@

# build source
WORKDIR @(ws)
RUN catkin init \
    && catkin build \
    -vi \
    --cmake-args \
    @(' \\\n    '.join(cmake_args))@

@[end if]@
@[end if]@

# setup environment
EXPOSE 11345

@[if 'entrypoint_name' in locals()]@
@[if entrypoint_name]@
@{
entrypoint_file = entrypoint_name.split('/')[-1]
}@
# setup entrypoint
COPY ./@entrypoint_file /

ENTRYPOINT ["/@entrypoint_file"]
@[end if]@
@[end if]@
@{
cmds = [
'gzserver',
]
}@
CMD ["@(' && '.join(cmds))"]
