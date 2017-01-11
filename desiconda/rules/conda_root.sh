curl -SL @MINICONDA@ \
    -o miniconda.sh \
    && /bin/bash miniconda.sh -b -f -p @CONDA_ROOT@ \
    && rm miniconda.sh \
    && rm -rf @CONDA_ROOT@/pkgs/*
