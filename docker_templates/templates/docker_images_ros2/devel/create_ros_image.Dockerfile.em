@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
))@
ARG FROM_IMAGE=@base_image
FROM $FROM_IMAGE
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

@(TEMPLATE(
    'snippet/setup_ros_sources.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
    ros2distro_name='rolling',
    rosdistro_name='',
    ros_version=ros_version,
))@

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_version=ros_version,
))@

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
@(TEMPLATE(
    'snippet/check_pytest_regression.Dockerfile.em',
))@
@
# bootstrap rosdep
@[if 'rosdep' in locals()]@
@[  if 'rosdistro_index_url' in rosdep]@
ENV ROSDISTRO_INDEX_URL @(rosdep['rosdistro_index_url'])
@[  end if]@
@[end if]@
RUN rosdep init \
    && rosdep update

@(TEMPLATE(
    'snippet/setup_colcon_mixin_metadata.Dockerfile.em',
))@

# clone source
ENV ROS2_WS @(ws)
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS

# build source
RUN colcon \
    build \
    --cmake-args \
      -DSECURITY=ON --no-warn-unused-cli \
    --symlink-install

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
