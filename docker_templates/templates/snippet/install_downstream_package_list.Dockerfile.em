@{
if isinstance(packages, list):
    if isinstance(downstream_packages, list):
        for pkg in downstream_packages:
            if pkg not in packages:
                packages.append(pkg)
}@
@[if isinstance(packages, list)]@
@[  if packages != []]@

# install packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    @(' \\\n    '.join(sorted(packages)))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
