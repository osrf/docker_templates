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
}@
@(TEMPLATE(
    'snippet/install_upstream_package_list.Dockerfile.em',
    packages=template_dependencies,
    upstream_packages=upstream_packages if 'upstream_packages' in locals() else [],
))@
@
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN . /etc/os-release \
    && echo "deb http://packages.osrfoundation.org/gazebo/$ID-stable `lsb_release -sc` main" > /etc/apt/sources.list.d/gazebo-latest.list

@[if 'gazebo_packages' in locals()]@
@[  if gazebo_packages]@

@(TEMPLATE(
    'snippet/label_and_install_package_list.Dockerfile.em',
    group='gazebo',
    packages=gazebo_packages,
))@
@[  end if]@
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
@{
cmds = [
'roslaunch drcsim_gazebo atlas.launch'
]
}@
CMD ["@(' && '.join(cmds))"]
