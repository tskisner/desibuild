curl -SL http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz \
    -o cfitsio3410.tar.gz \
    && tar xzf cfitsio3410.tar.gz \
    && cd cfitsio \
    && CC="@CC@" CFLAGS="@CFLAGS@" ./configure --prefix=@PREFIX@ \
    && make -j 4 && make shared && make install \
    && cd .. \
    && rm -rf cfitsio*
