@[if os_name == 'ubuntu']@

# setup timezone
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends --no-upgrade tzdata && \
    rm -rf /var/lib/apt/lists/*
@[end if]@
