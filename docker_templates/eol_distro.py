# Copyright 2019 Mikael Arguedas
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


def isDistroEOL(*, ros_distro_status=None, os_distro_name=None):
    if ros_distro_status == "end-of-life":
        return True
    eol_base_images = [
        # Ubuntu
        'lucid',
        'maverick',
        'natty',
        'oneiric',
        'precise',
        'quantal',
        'raring',
        'saucy',
        'trusty',
        'utopic',
        'vivid',
        'wily',
        'yakkety',
        'zesty',
        'artful',
        'cosmic',
        # Debian
        'wheezy',
        'jessie',
        'stretch',
    ]
    return os_distro_name in eol_base_images
