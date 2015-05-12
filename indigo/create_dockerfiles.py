#!/usr/bin/env python3

import os
import pkg_resources
import sys
import yaml

from collections import OrderedDict
try:
    from cStringIO import StringIO
except ImportError:
    from io import StringIO
from em import Interpreter

from ros_buildfarm.templates import create_dockerfile
from ros_buildfarm.common import get_debian_package_name


def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    """Load yaml data into an OrderedDict"""
    class OrderedLoader(Loader):
        pass

    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)


def main(argv=sys.argv[1:]):
    """Create Dockerfiles for images from platform and image yaml data"""

    platform_path = 'platform.yaml'
    images_path = 'images.yaml.em'
    base_path = os.path.dirname(__file__)

    # Ream platform perams
    with open(platform_path, 'r') as f:
        # use safe_load instead load
        platform = yaml.safe_load(f)['platform']

    # Ream image perams using platform perams
    images_yaml = StringIO()
    try:
        interpreter = Interpreter(output=images_yaml)
        interpreter.file(open(images_path, 'r'), locals=platform)
        images_yaml = images_yaml.getvalue()
    except Exception as e:
        print("Error processing %s" % images_path)
        raise
    finally:
        interpreter.shutdown()
        interpreter = None
    # Use ordered list
    images = ordered_load(images_yaml, yaml.SafeLoader)['images']

    # For each image tag
    for image in images:

        # Get data for image
        data = dict(images[image])
        data['tag_name'] = image

        # Add platform perams
        data.update(platform)

        # Get debian package names for ros
        ros_packages = []
        for ros_package_name in data['ros_packages']:
            ros_packages.append(
                get_debian_package_name(
                    data['rosdistro_name'], ros_package_name))
        data['ros_packages'] = ros_packages

        # Get path to save Docker file
        dockerfile_dir = os.path.join(base_path, image)
        data['dockerfile_dir'] = dockerfile_dir

        # generate Dockerfile
        create_dockerfile(data)

if __name__ == '__main__':
    main()
