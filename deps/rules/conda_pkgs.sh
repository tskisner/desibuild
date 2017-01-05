conda config --add channels intel \
    && conda install --yes intelpython3_core \
    && conda install --yes \
    requests \
    numpy \
    scipy \
    matplotlib \
    pyyaml \
    astropy \
    h5py \
    ipython-notebook \
    psutil \
    && rm -rf @CONDA_ROOT@/pkgs/*
