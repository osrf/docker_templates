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

# setup keys
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -

# setup sources.list
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-latest.list

# install gazebo packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(gazebo_packages))@


# setup environment
RUN echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc

EXPOSE 11345
ENTRYPOINT ["bash", "-c"]
@{
cmds = [
'bash',
]
}@
CMD ["@(' && '.join(cmds))"]
