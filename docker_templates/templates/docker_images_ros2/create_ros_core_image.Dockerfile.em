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
@
@(TEMPLATE(
    'snippet/old_release_set.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
))@
@
@(TEMPLATE(
    'snippet/setup_tzdata.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
))@
@
@{
template_dependencies = [
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
@
@(TEMPLATE(
    'snippet/setup_ros_sources.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
    ros2distro_name=ros2distro_name,
    rosdistro_name='',
    ros_version=ros_version,
))@

@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_version=ros_version,
))@

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV ROS_DISTRO @ros2distro_name
# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

@(TEMPLATE(
    'snippet/setup_colcon_mixin_metadata.Dockerfile.em',
))@

@[if 'pip3_install' in locals()]@
@[  if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[  end if]@
@[end if]@

# install ros2 packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros2_packages))@  \
    && rm -rf /var/lib/apt/lists/*

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
