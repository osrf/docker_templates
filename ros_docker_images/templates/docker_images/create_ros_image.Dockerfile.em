@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
    now_str=now_str,
))@
@(TEMPLATE(
    'snippet/from_base_image.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
    arch=arch,
    base_image=base_image,
    base_name=base_name,
    base_tag_name=base_tag_name,
))@
MAINTAINER Dirk Thomas dthomas+buildfarm@@osrfoundation.org

# install requested metapackage
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@


ENTRYPOINT ["bash", "-c"]
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]