import os

from setuptools import find_packages
from setuptools import setup

# get version number from module
version_file = os.path.join(
    os.path.dirname(__file__), 'docker_templates', '_version.py')
exec(open(version_file).read())

# Get a list of scripts to install
scripts = []
for root, dirnames, filenames in os.walk('scripts'):
    # don't install the wrapper scripts
    # since they would overlay Python packages with the same name
    if 'wrapper' in dirnames:
        dirnames.remove('wrapper')
    for filename in filenames:
        if not filename.endswith('.py'):
            continue
        scripts.append(os.path.join(root, filename))

# Get the long description out of the readme.md
with open(os.path.join(os.path.dirname(__file__), 'README.md'), 'r') as f:
    long_description = f.read()

install_requires = [
    'empy',
    'pyyaml',
    'ros_buildfarm',
]

kwargs = {
    'name': 'docker_templates',
    'version': __version__,
    'packages': find_packages(exclude=['test']),
    'scripts': scripts,
    'include_package_data': True,
    'zip_safe': False,
    'package_dir': {'docker_templates': 'docker_templates'},
    'package_data': {'docker_templates': ['templates/docker_images/*.em']},
    'install_requires': install_requires,
    'author': 'Tully Foote',
    'author_email': 'tfoote@osrfoundation.org',
    'maintainer': 'Tully Foote',
    'maintainer_email': 'tfoote@osrfoundation.org',
    'url': 'https://github.com/osrf/docker_images',
    'keywords': ['ROS', 'docker'],
    'classifiers': [
        'Programming Language :: Python',
        'License :: OSI Approved :: Apache Software License'],
    'description': "A package to generate Docker Base Images.",
    'long_description': long_description,
    'license': 'Apache 2.0',
}


if 'SKIP_PYTHON_MODULES' in os.environ:
    kwargs['packages'] = []
elif 'SKIP_PYTHON_SCRIPTS' in os.environ:
    kwargs['name'] += '_modules'
    kwargs['scripts'] = []
# else:
#     kwargs['install_requires'] += ['catkin_pkg >= 0.2.6', 'rosdistro >= 0.4.0']

setup(**kwargs)
