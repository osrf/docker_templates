@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
    now_str=now_str,
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

RUN apt-get update && apt-get install -y \
    software-properties-common  \
    && rm -rf /var/lib/apt/lists/*

RUN apt-add-repository ppa:libccd-debs \
    && apt-add-repository ppa:fcl-debs \
    && apt-add-repository ppa:dartsim

@[if 'ros_packages' in locals()]@
@[if ros_packages]@
# ROS Setup ####################################################################
# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/@os_name @os_code_name main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
ENV ROS_DISTRO @rosdistro_name
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros_packages))@  \
    && rm -rf /var/lib/apt/lists/*
@[end if]@
@[end if]@

@[if 'gazebo_packages' in locals()]@
@[if gazebo_packages]@
# Gazebo Setup #################################################################
# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-latest.list

# install gazebo packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(gazebo_packages))@  \
    && rm -rf /var/lib/apt/lists/*
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
