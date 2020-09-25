@[if packages]@
# label @group packages
LABEL @(' \\\n      '.join('sha256.{name}={sha256}'.format(**p) for p in packages))@


# install @group packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    @(' \\\n    '.join('{name}{version}'.format(**p) for p in packages))@  \
    && rm -rf /var/lib/apt/lists/*
@[end if]
