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

# setup keys
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN . /etc/os-release \
    && echo "deb http://packages.ros.org/ros/$ID $VERSION_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list

# setup keys
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN . /etc/os-release \
    && echo "deb http://packages.osrfoundation.org/gazebo/$ID-stable $VERSION_CODENAME main" > /etc/apt/sources.list.d/gazebo-latest.list

@[if 'packages' in locals()]@
@[if packages]@
# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@[end if]@
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

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
ENV ROS2_WS @(ws)
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS
@(TEMPLATE(
    'snippet/vcs_import.Dockerfile.em',
    vcs=vcs,
    ws='src',
))@

@[end if]@
@[end if]@
@[if 'ament_args' in locals()]@
@[if ament_args]@
# build source
WORKDIR $ROS2_WS
RUN src/ament/ament_tools/scripts/ament.py \
    @(' \\\n    '.join(ament_args))@


@[end if]@
@[end if]@
# setup bashrc
RUN cp /etc/skel/.bashrc ~/

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
