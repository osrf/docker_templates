@[if 'vcs' in locals()]@
@[  if vcs]@
@[    for i, (imports_name, imports) in enumerate(vcs.items())]@
@{
if imports['repos'] is None:
    imports['repos'] = "https://raw.githubusercontent.com/ros2/ros2/release-$ROS_DISTRO/ros2.repos"
}@
RUN wget @(imports['repos']) \
    && vcs import @(ws) < @(imports['repos'].split('/')[-1])
@[    end for]@
@[  end if]@
@[end if]@
