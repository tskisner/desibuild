FROM ubuntu:16.04

MAINTAINER Theodore Kisner <tskisner@lbl.gov>

# Use bash

SHELL ["/bin/bash", "-c"]

# Install system dependencies.

RUN apt-get update \
    && apt-get install -y curl procps build-essential gfortran git \
    && rm -fr /var/lib/apt/lists/*

# Make all the directories we are going to need.  This
# includes the conda install prefix and the DESI volume
# mount points.

RUN mkdir -p /usr/local/conda/bin \
    && mkdir -p /usr/local/conda/lib \
    && mkdir -p /usr/local/lib/python3.5/site-packages \
    && mkdir -p /desi/spectro_data \
    && mkdir -p /desi/spectro_redux \
    && mkdir -p /desi/root \
    && mkdir -p /desi/model

# Set all environment variables we need. Note that we
# add the conda library and include directories to our
# environment as well, since we will be installing
# compatible MKL headers and using the conda MKL install
# for compiled packages.  Since we are not using modules
# or other TCL based scripts, it should be OK to have the
# conda TCL/TK installation in our LD_LIBRARY_PATH.

# At run time, the user must specify the mount points for 
# /desi/spectro_data, /desi/spectro_redux, /desi/root,
# and /desi/model.  The user must also set the environment 
# variable for SPECPROD.  Currently DESI_BASIS_TEMPLATES 
# is hard-coded to a subdirectory of DESI_ROOT, but we 
# should change that.

ENV PATH /usr/local/bin:/usr/local/conda/bin:/usr/bin:/bin:/usr/sbin:/sbin
ENV CPATH /usr/local/include:/usr/local/conda/include:/usr/include
ENV LIBRARY_PATH /usr/local/lib:/usr/local/conda/lib:/usr/lib
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/conda/lib:/usr/lib
ENV PYTHONPATH /usr/local/lib/python3.5/site-packages

ENV DESI_ROOT /desi/root
ENV DESIMODEL /desi/model
ENV DESI_SPECTRO_DATA /desi/spectro_data
ENV DESI_SPECTRO_REDUX /desi/spectro_redux
ENV DESI_BASIS_TEMPLATES "${DESI_ROOT}/spectro/templates/basis_templates/v2.2"

# Create working directory for builds

RUN mkdir /usr/src/desi
WORKDIR /usr/src/desi

# Install conda root environment

RUN curl -SL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -o miniconda.sh \
    && /bin/bash miniconda.sh -b -f -p /usr/local/conda \
    && rm miniconda.sh \
    && rm -rf /usr/local/conda/pkgs/*

# Install conda packages.

RUN conda install --yes \
    requests \
    numpy \
    scipy \
    matplotlib \
    pyyaml \
    astropy \
    h5py \
    ipython-notebook \
    psutil \
    && rm -rf /usr/local/conda/pkgs/*

# Install pip packages.

RUN pip install --no-binary :all: \
    fitsio \
    speclite \
    iniparser \
    hpsspy

# Copy MKL 11.3.3 headers into conda root

ADD mkl_11.3.3_include.tar.gz /usr/local/conda/include/

# Install MPICH 3.2 which is compatible with the external
# Cray MPICH which is prepended to LD_LIBRARY_PATH as part
# of shifter.

RUN curl -SL http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz \
    -o mpich-3.2.tar.gz \
    && tar -xzf mpich-3.2.tar.gz \
    && cd mpich-3.2 \
    && ./configure --prefix=/usr/local \
    && make -j 4 && make install \
    && cd .. \
    && rm -rf mpich-3.2*

# Install mpi4py.

RUN curl -SL https://pypi.python.org/packages/ee/b8/f443e1de0b6495479fc73c5863b7b5272a4ece5122e3589db6cd3bb57eeb/mpi4py-2.0.0.tar.gz#md5=4f7d8126d7367c239fd67615680990e3 \
    -o mpi4py-2.0.0.tar.gz \
    && tar xzf mpi4py-2.0.0.tar.gz \
    && cd mpi4py-2.0.0 \
    && python setup.py install --prefix=/usr/local \
    && cd .. \
    && rm -rf mpi4py*

# Install CFITSIO.

RUN curl -SL http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz \
    -o cfitsio3410.tar.gz \
    && tar xzf cfitsio3410.tar.gz \
    && cd cfitsio \
    && CFLAGS="-O3 -fPIC" ./configure --prefix=/usr/local \
    && make -j 4 && make shared && make install \
    && cd .. \
    && rm -rf cfitsio*

# Install FFTW.

RUN curl -SL http://www.fftw.org/fftw-3.3.5.tar.gz \
    -o fftw-3.3.5.tar.gz \
    && tar xzf fftw-3.3.5.tar.gz \
    && cd fftw-3.3.5 \
    && CFLAGS="-O3 -fPIC" ./configure --enable-threads --prefix=/usr/local \
    && make -j 4 && make install \
    && cd .. \
    && rm -rf fftw*

# Install BOOST.

RUN curl -SL https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2/download \
    -o boost_1_62_0.tar.bz2 \
    && tar xjf boost_1_62_0.tar.bz2 \
    && cd boost_1_62_0 \
    && echo "" > tools/build/user-config.jam \
    && echo 'using gcc : : g++ : <cflags>"-O3 -fPIC" <cxxflags>"-O3 -fPIC" ;' >> tools/build/user-config.jam \
    && echo 'using mpi : mpicxx : <find-shared-library>mpichcxx <find-shared-library>mpich ;' >> tools/build/user-config.jam \
    && BOOST_BUILD_USER_CONFIG=tools/build/user-config.jam ./bootstrap.sh \
    --with-toolset=gcc \
    --with-python=python3 \
    --prefix=/usr/local \
    && BOOST_BUILD_USER_CONFIG=tools/build/user-config.jam ./b2 \
    --layout=tagged \
    $(python3-config --includes | sed -e 's/-I//g' -e 's/\([^[:space:]]\+\)/ include=\1/g') \
    variant=release threading=multi link=shared runtime-link=shared install \
    && cd .. \
    && rm -rf boost*

# Install HARP.

RUN curl -SL https://github.com/tskisner/HARP/releases/download/v1.0.1/harp-1.0.1.tar.gz \
    -o harp-1.0.1.tar.gz \
    && tar xzf harp-1.0.1.tar.gz \
    && cd harp-1.0.1 \
    && CFLAGS="-O3 -fPIC" CXXFLAGS="-O3 -fPIC" ./configure \
    --disable-mpi --disable-python \
    --with-cfitsio=/usr/local \
    --with-boost=/usr/local \
    --with-blas="-L/usr/local/conda/lib -lmkl_rt -fopenmp -lpthread -lm -ldl" \
    --prefix=/usr/local \
    && make -j 4 && make install \
    && cd .. \
    && rm -rf harp*

# Install desibuild, to facilitate installation of DESI packages.  Then
# install all desi packages based on the version file.

COPY desi_versions.txt /usr/local/

RUN git clone https://github.com/tskisner/desibuild.git \
    && ./desibuild/desi_source /usr/local/desi_versions.txt \
    && ./desibuild/desi_setup -c -p /usr/local -v /usr/local/desi_versions.txt \
    && rm -rf desi*

# Set the entrypoint and default command

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]

