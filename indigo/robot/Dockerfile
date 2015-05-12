# generated from templates/docker_images/create_ros_base_image.Dockerfile.em

FROM ros:indigo-ros-base
MAINTAINER Dirk Thomas dthomas+buildfarm@osrfoundation.org

# install requested metapackage
RUN apt-get update && apt-get install -q -y \
    ros-indigo-robot

ENTRYPOINT ["bash", "-c"]
CMD ["bash"]
