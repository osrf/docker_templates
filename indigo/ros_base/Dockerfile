# generated from templates/docker_images/create_ros_base_image.Dockerfile.em

FROM ros:indigo-ros-core
MAINTAINER Dirk Thomas dthomas+buildfarm@osrfoundation.org

# install requested metapackage
RUN apt-get update && apt-get install -q -y \
    ros-indigo-ros-base

ENTRYPOINT ["bash", "-c"]
CMD ["bash"]
