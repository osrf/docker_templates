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
@[if 'packages' in locals()]@
@[  if packages]@

# install packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
@[if 'ros_packages' in locals()]@
@[  if ros_packages]@

# install ros packages
RUN apt-get update && apt-get install -y \
    @(' \\\n    '.join(ros_packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
