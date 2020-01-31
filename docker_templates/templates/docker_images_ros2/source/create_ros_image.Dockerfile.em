@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
))@

ARG FROM_IMAGE=osrf/ros2:devel
FROM $FROM_IMAGE
@{
template_dependencies = [
    'wget',
]
packages_to_install = []
if 'upstream_packages' in locals():
    packages_to_install = upstream_packages
if 'ros2_repo_packages' in locals():
    if ros2_repo_packages:
        packages_to_install = packages_to_install + list(set(ros2_repo_packages) - set(packages_to_install))
}@
@
@(TEMPLATE(
    'snippet/install_upstream_package_list.Dockerfile.em',
    packages=template_dependencies,
    upstream_packages=packages_to_install,
))@
@
@[if 'pip3_install' in locals()]@
@[  if pip3_install]@

# install python packages
RUN pip3 install -U \
    @(' \\\n    '.join(pip3_install))@


@[  end if]@
@[end if]@
ARG ROS_DISTRO=@ros2_distro
ENV ROS_DISTRO=$ROS_DISTRO
ENV ROS_VERSION=2 \
    ROS_PYTHON_VERSION=3

@
@[if 'rosdep' in locals()]@
@[  if 'rosdistro_index_url' in rosdep]@
ENV ROSDISTRO_INDEX_URL @(rosdep['rosdistro_index_url'])
RUN rosdep update --rosdistro $ROS_DISTRO

@[  end if]@
@[end if]@
@
WORKDIR $ROS2_WS
@[if 'vcs' in locals()]@
@[  if vcs]@

@(TEMPLATE(
    'snippet/vcs_import.Dockerfile.em',
    vcs=vcs,
    ws='src',
))@

@[  end if]@
@[end if]@
@
@[if 'rosdep' in locals()]@
@[  if 'install' in rosdep]@
@(TEMPLATE(
    'snippet/install_rosdep_dependencies.Dockerfile.em',
    install_args=rosdep['install'],
))@

@[  end if]@
@[else]@
RUN rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -y \
    --from-paths src \
    --ignore-src

@[end if]@
@[if 'colcon_args' in locals()]@
@[  if colcon_args]@
# build source
RUN colcon \
    @(' \\\n    '.join(colcon_args))@

@[  end if]@
@[end if]@

ARG RUN_TESTS
ARG FAIL_ON_TEST_FAILURE
RUN if [ ! -z "$RUN_TESTS" ]; then \
        colcon test; \
        if [ ! -z "$FAIL_ON_TEST_FAILURE" ]; then \
            colcon test-result; \
        else \
            colcon test-result || true; \
        fi \
    fi
@
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
