#!/usr/bin/env python3

import yaml

from collections import OrderedDict


def OrderedLoad(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
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
