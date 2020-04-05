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
    'snippet/install_upstream_package_list.Dockerfile.em',
    packages=[],
    upstream_packages=upstream_packages if 'upstream_packages' in locals() else [],
))@
@
@[if 'bootstrap_ros_tools' in locals()]@
@(TEMPLATE(
    'snippet/install_ros_bootstrap_tools.Dockerfile.em',
    ros_version=ros_version,
))@

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

@[end if]@
@
@[if 'ros_packages' in locals()]@
@[  if ros_packages]@
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    @(' \\\n    '.join(ros_packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
