# install dependencies
RUN apt-get update && rosdep install -y \
    @(' \\\n    '.join(sorted(install_args)))@  \
    && rm -rf /var/lib/apt/lists/*
