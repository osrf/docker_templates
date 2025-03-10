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
@{
template_dependencies = []
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
@[if 'pip3_install' in locals()]@
@[  if pip3_install]@
# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@

@[  end if]@
@[end if]@

@(TEMPLATE(
    'snippet/setup_ros_sources.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
    ros_distro=rosdistro_name,
))@

ENV ROS1_DISTRO=@rosdistro_name
ENV ROS2_DISTRO=@ros2distro_name

@[if 'ros_packages' in locals()]@
@(TEMPLATE(
    'snippet/copy_and_install_package_list.Dockerfile.em',
    group='ros',
    package_type='ros_packages',
    packages=ros_packages,
))@
@[end if]@
@[if 'ros2_packages' in locals()]@
@(TEMPLATE(
    'snippet/copy_and_install_package_list.Dockerfile.em',
    group='ros',
    package_type='ros2_packages',
    packages=ros2_packages,
))@
@[end if]@
@[if 'downstream_packages' in locals()]@
@[  if downstream_packages]@
# install downstream packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    @(' \\\n    '.join(downstream_packages))@  \
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
@[  end if]@	
@[end if]@
