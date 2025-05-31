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
    'snippet/old_release_set.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
))@

@[if 'packages' in locals()]@
@[  if packages]@

# install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/lib/apt/lists/partial

@[  end if]@
@[end if]@
@
@(TEMPLATE(
    'snippet/setup_ros_sources.Dockerfile.em',
    os_name=os_name,
    os_code_name=os_code_name,
    rosdistro_name=rosdistro_name,
    ros_version=1,
))@

# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# install ros packages
ENV ROS_DISTRO=@rosdistro_name
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join('{name}{version}'.format(**p) for p in ros_packages))@  \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/lib/apt/lists/partial

@[if 'entrypoint_name' in locals()]@
@[  if entrypoint_name]@
@{
entrypoint_file = entrypoint_name.split('/')[-1]
}@
# setup entrypoint
COPY ./@entrypoint_file /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
@[  end if]@
@[end if]@
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
