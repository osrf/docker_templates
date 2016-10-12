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

# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
@[if 'packages' in locals()]@
@[if packages]@

# install packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@[end if]@

# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/@os_name @os_code_name main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO @rosdistro_name
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros_packages))@  \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
COPY ./ros_entrypoint.sh /

@[if 'entrypoint_name' in locals()]@
@[if entrypoint_name]@
@{
entrypoint_file = entrypoint_name.split('/')[-1]
}@
ENTRYPOINT ["/@entrypoint_file"]
@[end if]@
@[end if]@
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
