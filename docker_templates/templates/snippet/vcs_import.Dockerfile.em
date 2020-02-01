@[if 'vcs' in locals()]@
@[  if vcs]@
@[    if 'imports' in vcs.keys()]@
@[      if vcs['imports'] is None]@
@{        vcs['imports'] = {'ros2.repos': 'https://raw.githubusercontent.com/ros2/ros2/$ROS_DISTRO-release/ros2.repos'}}@
@[      end if]@
@[      for imports_name, imports_url in vcs['imports'].items()]@
RUN wget @(imports_url) -O @(imports_name) \
    && vcs import @(ws) < @(imports_name)
@[      end for]@
@[    end if]@
@[  end if]@
@[end if]@
