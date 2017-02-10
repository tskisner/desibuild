# Building Docker Images of DESI Tools

In order to build docker images containing DESI software, first ensure
that you have done a "docker pull" of the desired version of the desiconda
docker image.  Then make sure that the Dockerfile in this directory points
to the correct version of the desiconda image.


## Set the Versions

Edit the "desi_versions.txt" file to point to the branches / tags of each
packages you are installing.  This file will be passed to the desibuild
scripts when run inside the image.


## Build the Image

Now use the normal docker commands to build the image::

    $> docker build . -f Dockerfile_desipipe

After this is done you can do the usual tagging of the image and push to 
dockerhub.

