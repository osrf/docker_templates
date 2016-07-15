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

# ROS1 Repo Setup ##############################################################
# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/@os_name @os_code_name main" > /etc/apt/sources.list.d/ros-latest.list

# OSRF Repo Setup ##############################################################
# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable @os_code_name main" > /etc/apt/sources.list.d/gazebo-latest.list

# ROS2 Setup ###################################################################
@[if 'packages' in locals()]@
@[if packages]@
# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*
@[end if]@
@[end if]@

@[if 'pip3_install' in locals()]@
@[if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[end if]@
@[end if]@

@[if 'vcs' in locals()]@
@[if vcs]@
# clone source
ENV WS @(ws)
RUN mkdir -p @(ws)
@(TEMPLATE(
    'snippet/vcs_import.Dockerfile.em',
    vcs=vcs,
    ws=ws,
))@
@[end if]@
@[end if]@

@[if 'ament_args' in locals()]@
@[if ament_args]@
# build source
WORKDIR @(ws)/..
RUN src/ament/ament_tools/scripts/ament.py \
    @(' \\\n    '.join(ament_args))@

@[end if]@
@[end if]@

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
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
