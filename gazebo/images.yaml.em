%YAML 1.1
# ROS Dockerfile database
---
images:
    gzserver@(version):
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_gazebo_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        gazebo_packages:
            - gazebo@(version)
    gzweb@(version):
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_gazebo_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        gazebo_packages:
            - gazebo@(version)
    gzclient@(version):
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_gazebo_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        gazebo_packages:
            - gazebo@(version)
    gazebo@(version):
        base_image: @(user_name):gzserver@(version)
        template_name: docker_images/create_gazebo_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        gazebo_packages:
            - gazebo@(version)
    gazebo@(version)-dev:
        base_image: @(user_name):gazebo@(version)
        template_name: docker_images/create_gazebo_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        gazebo_packages:
            - libgazebo@(version)-dev
