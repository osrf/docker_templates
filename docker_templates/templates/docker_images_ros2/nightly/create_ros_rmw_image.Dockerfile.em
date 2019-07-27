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

@[if 'rosdep' in locals()]@
@{
if 'path' not in rosdep:
  rosdep['path']='/opt/ros/$ROS_DISTRO/share'
}@
# install dependencies
ENV RTI_NC_LICENSE_ACCEPTED=yes
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && apt-get update \
    && rosdep install -y \
    --from-paths @(rosdep['path']) \
    --ignore-src \
    --skip-keys " \
      @(' \\\n      '.join(rosdep['skip_keys']))@ " \
    && rm -rf /var/lib/apt/lists/*
@[end if]@
