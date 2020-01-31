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
@[if 'env_before' in locals()]@

@[  for env_var, env_val in env_before.items()]@
ENV @(env_var) @(env_val)
@[  end for]@
@[end if]@
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
@
@[if 'rosdep' in locals()]@
# bootstrap rosdep
RUN rosdep update --rosdistro $ROS_DISTRO

@{
if 'path' not in rosdep:
  rosdep['path'] = '/opt/ros/$ROS_DISTRO/share'
if 'skip_keys' not in rosdep:
  rosdep['skip_keys'] = []
}@
# install dependencies
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && apt-get update \
    && rosdep install -y \
    --from-paths @(rosdep['path']) \
    --ignore-src \
    --skip-keys " \
      @(' \\\n      '.join(rosdep['skip_keys']))@ " \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@
@[if 'env_after' in locals()]@

# set up environment
@[  for env_var, env_val in env_after.items()]@
ENV @(env_var) @(env_val)
@[  end for]@
@[end if]@
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
