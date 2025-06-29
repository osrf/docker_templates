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
    'ca-certificates',
    'curl',
    'dirmngr',
    'gnupg2',
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
    ros_distro='rolling',
    testing_repo=True,
))@

@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_distro='rolling',
))@

# setup environment
ENV ROS_DISTRO=@ros2distro_name
@[if 'env_before' in locals()]@
@[  for env_var, env_val in env_before.items()]@
ENV @(env_var)=@(env_val)
@[  end for]@

@[end if]@
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
# bootstrap rosdep
@[if 'rosdep' in locals()]@
@[  if 'rosdistro_index_url' in rosdep]@
ENV ROSDISTRO_INDEX_URL=@(rosdep['rosdistro_index_url'])
@[  end if]@
@[end if]@
RUN rosdep init \
    && rosdep update --rosdistro $ROS_DISTRO

@(TEMPLATE(
    'snippet/setup_colcon_mixin_metadata.Dockerfile.em',
))@

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
