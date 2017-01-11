conda config --add channels intel \
    && conda install --yes intelpython3_core \
    && rm -rf @CONDA_ROOT@/pkgs/*
