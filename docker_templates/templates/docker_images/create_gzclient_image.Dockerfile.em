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

@(TEMPLATE(
    'snippet/label_and_install_package_list.Dockerfile.em',
    group='gazebo',
    packages=gazebo_packages,
))@
