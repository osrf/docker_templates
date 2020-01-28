# Copyright 2015-2016 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import git
import os
import string


def latest_commit_sha(repo, path):
    """That the last commit sha for a given path in repo"""
    log_message = repo.git.log("-1", path)
    commit_sha = log_message.split('\n')[0].split(' ')[1]
    return commit_sha


def parse_manifest(manifest, repo, repo_name):
    # For each release
    for release_name, release_data in list(manifest['release_names'].items()):
        print('release_name: ', release_name)
        # For each os supported
        at_least_one_tag = False
        for os_name, os_data in list(release_data['os_names'].items()):
            print('os_name: ', os_name)
            # For each os code name supported
            for os_code_name, os_code_data in list(os_data['os_code_names'].items()):
                print('os_code_name: ', os_code_name)
                if os_code_data['tag_names']:
                    at_least_one_tag = True
                    for tag_name, tag_data in os_code_data['tag_names'].items():
                        print('tag_name: ', tag_name)
                        tags = []
                        for alias_pattern in tag_data['aliases']:
                            alias_template = string.Template(alias_pattern)
                            alias = alias_template.substitute(
                                release_name=release_name,
                                os_name=os_name,
                                os_code_name=os_code_name)
                            tags.append(alias)
                        commit_path = os.path.join(
                            repo_name, release_name,
                            os_name, os_code_name, tag_name)
                        commit_sha = latest_commit_sha(repo, commit_path)
                        print('tags: ', tags)
                        tag_data['Tags'] = tags
                        tag_data['Architectures'] = os_code_data['archs']
                        tag_data['GitCommit'] = commit_sha
                        tag_data['Directory'] = commit_path
        if not at_least_one_tag:
            del manifest['release_names'][release_name]

    return manifest
