# Building Docker Images of DESI Tools

In order to build docker images containing DESI software, first ensure
that you have done a "docker pull" of the desired version of the desiconda
docker image.  Then make sure that the Dockerfile in this directory points
to the correct version of the desiconda image.


## Set the Versions

By default the docker file uses the stable versions of all packages.  You
can obviously modify the docker file to use a different versions file.


## Build the Image

Now use the normal docker commands to build the image::

    $> docker build . -f Dockerfile_desipipe

After this is done you can do the usual tagging of the image and push to 
dockerhub.

