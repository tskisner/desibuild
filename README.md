# Scripts and Tools for Installation of DESI Software

The idea behind these scripts is to keep them as simple as possible, but
no simpler.


## Dependencies

Get all the dependencies into your environment before using these tools.
At NERSC, you can load the "desi-conda" module.  On other systems, you 
could look at the documentation here::

    http://desispec.readthedocs.io/en/latest/install.html


## Get your source trees

Copy the versions.txt file to something, and add packages or adjust branch
names as needed.  Then make a working directory and get the source::

    $>  mkdir build
    $>  cd build
    $>  ../desi_source my_versions.txt

## Install your packages

Decide where you want to install things.
