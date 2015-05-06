import os

from setuptools import find_packages
from setuptools import setup

# get version number from module
version_file = os.path.join(
    os.path.dirname(__file__), 'ros_docker_images', '_version.py')
exec(open(version_file).read())

# Get a list of scripts to install
scripts = []
for root, dirnames, filenames in os.walk('scripts'):
    for filename in filenames:
        scripts.append(os.path.join(root, filename))

install_requires = [
    'catkin-pkg >= 0.2.6',
    'empy',
    'PyYAML',
    'rosdistro >= 0.4.0',
    'ros_buildfarm',
]

# Get the long description out of the readme.md
with open(os.path.join(os.path.dirname(__file__), 'README.md'), 'r') as f:
    long_description = f.read()

setup(
    name='ros_docker_images',
    version=__version__,
    package_dir={'ros_docker_images': 'ros_docker_images'},
    packages=find_packages(exclude=['test']),
    scripts=scripts,
    package_data={'ros_docker_images': ['templates/docker_images/*.em']},
    include_package_data=True,
    zip_safe=False,
    install_requires=install_requires,
    author='Tully Foote',
    author_email='tfoote@osrfoundation.org',
    maintainer='Tully Foote',
    maintainer_email='tfoote@osrfoundation.org',
    url='https://github.com/ros-infrastructure/docker_images',
    keywords=['ROS', 'docker'],
    classifiers=['Programming Language :: Python',
                 'License :: OSI Approved :: Apache Software License'],
    description="A package to generate Docker Base Images.",
    long_description=long_description,
    license='Apache 2.0',
)
