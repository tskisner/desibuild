curl -SL https://github.com/tskisner/HARP/releases/download/v1.0.1/harp-1.0.1.tar.gz \
    -o harp-1.0.1.tar.gz \
    && tar xzf harp-1.0.1.tar.gz \
    && cd harp-1.0.1 \
    && CC="@CC@" CXX="@CXX@" CFLAGS="@CFLAGS@" CXXFLAGS="@CXXFLAGS@" ./configure \
    --disable-mpi --disable-python \
    --with-cfitsio=@PREFIX@ \
    --with-boost=@PREFIX@ \
    --with-blas="@BLAS@" \
    --with-lapack="@LAPACK@" \
    --prefix=@PREFIX@ \
    && make -j 4 && make install \
    && cd .. \
    && rm -rf harp*
