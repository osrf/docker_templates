@{
releases_with_configured_tzdata = [
    'artful',
    'lucid',
    'maverick',
    'nutty',
    'oneiric',
    'precise',
    'quantal',
    'raring',
    'saucy',
    'trusty',
    'utopic',
    'vivid',
    'wily',
    'xenial',
    'yakkety',
    'zesty',
]
}@
@[if os_name == 'ubuntu' and os_code_name not in releases_with_configured_tzdata]@

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

@[end if]@
