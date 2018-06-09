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
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN . /etc/os-release \
    && echo "deb http://repo.ros2.org/$ID/main `lsb_release -sc` main" > /etc/apt/sources.list.d/ros2-latest.list

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

@{
# add colcon packages to 'ros2_repo_packages' if colcon is used
if 'colcon_args' in locals():
    colcon_packages = [
        'python3-colcon-common-extensions',
    ]
    ros2_repo_packages.extend(colcon_packages)
}@
@[if 'ros2_repo_packages' in locals()]@
@[  if ros2_repo_packages]@
# install packages from the ROS repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    @(' \\\n    '.join(sorted(ros2_repo_packages)))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
@
@[if 'pip3_install' in locals()]@
@[  if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[  end if]@
@[end if]@
@
@[if 'vcs' in locals()]@
@[  if vcs]@

# clone source
ENV ROS2_WS @(ws)
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS
@(TEMPLATE(
    'snippet/vcs_import.Dockerfile.em',
    vcs=vcs,
    ws='src',
))@

@[  end if]@
@[end if]@
@[if 'colcon_args' in locals()]@
@[  if colcon_args]@
# build source
WORKDIR $ROS2_WS
RUN colcon \
    @(' \\\n    '.join(colcon_args))@


@[  end if]@
@[end if]@
# setup bashrc
RUN cp /etc/skel/.bashrc ~/

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
