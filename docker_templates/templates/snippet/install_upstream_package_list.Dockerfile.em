@{
if isinstance(packages, list):
    if isinstance(upstream_packages, list):
        for pkg in upstream_packages:
            if pkg not in packages:
                packages.append(pkg)
}@
@[if isinstance(packages, list)]@
@[  if packages != []]@

# install packages
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    @(' \\\n    '.join(sorted(packages)))@  \
    && rm -rf /var/lib/apt/lists/*

@[  end if]@
@[end if]@
