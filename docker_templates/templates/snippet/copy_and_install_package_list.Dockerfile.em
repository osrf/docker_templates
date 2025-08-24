@[if packages]@
# copy @group packages
ARG TARGETARCH
COPY @(package_type)/$TARGETARCH.txt /etc/apt/@(group)/@(package_type).txt

# install @group packages
RUN apt-get update \
    && xargs -a /etc/apt/@(group)/@(package_type).txt \
        apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
@[end if]
