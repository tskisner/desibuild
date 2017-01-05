curl -SL https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2/download \
    -o boost_1_62_0.tar.bz2 \
    && tar xjf boost_1_62_0.tar.bz2 \
    && cd boost_1_62_0 \
    && echo "" > tools/build/user-config.jam \
    && echo 'using @BOOSTCHAIN@ : : @CXX@ : <cflags>"@CFLAGS@" <cxxflags>"@CXXFLAGS@" ;' >> tools/build/user-config.jam \
    && echo 'using mpi : @MPICXX@ : <find-shared-library>@MPI_CXXLIB@ <find-shared-library>@MPI_LIB@ ;' >> tools/build/user-config.jam \
    && BOOST_BUILD_USER_CONFIG=tools/build/user-config.jam ./bootstrap.sh \
    --with-toolset=@BOOSTCHAIN@ \
    --with-python=python3 \
    --prefix=@PREFIX@ \
    && BOOST_BUILD_USER_CONFIG=tools/build/user-config.jam ./b2 \
    --layout=tagged \
    $(python3-config --includes | sed -e 's/-I//g' -e 's/\([^[:space:]]\+\)/ include=\1/g') \
    variant=release threading=multi link=shared runtime-link=shared install \
    && cd .. \
    && rm -rf boost*
