curl -SL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -o miniconda.sh \
    && /bin/bash miniconda.sh -b -f -p @CONDA_ROOT@ \
    && rm miniconda.sh \
    && rm -rf @CONDA_ROOT@/pkgs/*
