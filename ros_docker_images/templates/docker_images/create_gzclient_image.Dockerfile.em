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
))@
MAINTAINER Nate Koenig nkoenig@@osrfoundation.org
@[if 'packages' in locals()]@
@[if packages]@

# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@

@[end if]@
@[end if]@

# install gazebo packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(gazebo_packages))@


# setup environment
RUN echo "export QT_X11_NO_MITSHM=1" >> ~/.bashrc \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX

# install nvidia drivers
ADD nvidia-driver.run /tmp/nvidia-driver.run
RUN sh /tmp/nvidia-driver.run -a -N --ui=none --no-kernel-module \
	&& rm /tmp/nvidia-driver.run

ENTRYPOINT ["bash", "-c"]
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
