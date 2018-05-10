# generated from @template_name

@(TEMPLATE(
    'snippet/from_base_image.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
    arch=arch,
    maintainer_name=maintainer_name,
))@

@(TEMPLATE(
    'snippet/add_distribution_repositories.Dockerfile.em',
    distribution_repository_keys=distribution_repository_keys,
    distribution_repository_urls=distribution_repository_urls,
    os_code_name=os_code_name,
    add_source=True,
))@

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# install bootstrap tools
RUN apt-get update && apt-get install -q -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools

# setup environment
ENV LANG C.UTF-8
ENV TZ @timezone

# bootstrap rosdep
RUN rosdep init

# install requested metapackage
RUN apt-get update && apt-get install -q -y @(' '.join(packages))@

ENV ROS_DISTRO @(rosdistro)@
# TODO source rosdistro setup file automatically on entry
ENTRYPOINT ["bash", "-c"]
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
