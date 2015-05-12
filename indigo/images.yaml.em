%YAML 1.1
# ROS Dockerfile database
---
images:
    ros_core:
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_ros_core_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        ros_packages:
            - ros-core
    ros_base:
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_ros_core_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        ros_packages:
            - ros-base
    robot:
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_ros_core_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        ros_packages:
            - robot
    perception:
        base_image: @(os_name):@(os_code_name)
        template_name: docker_images/create_ros_core_image.Dockerfile.em
        template_packages:
            - ros_docker_images
        packages:
            - wget
        ros_packages:
            - perception
