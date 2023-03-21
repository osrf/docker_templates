@[if packages]@
# copy @group packages
ARG TARGETARCH
COPY $TARGETARCH/@(package_type).txt /opt/@(group)/

# install @group packages
RUN apt-get update \
    && xargs -a /opt/@(group)/@(package_type).txt \
        apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
@[end if]
