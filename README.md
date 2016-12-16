# Scripts and Tools for Installation of DESI Software

The idea behind these scripts is to keep them as simple as possible, but
no simpler.  **Disclaimer:**  These are the scripts I use when working on
pipeline development.  They are posted here in case someone finds them 
useful.  They are not official DESI products.

## Use Cases

Hopefully one of these situations describes what you are looking for...

### Someone Already Installed Everything, but I Want to Modify Package "X"

This is easy.  Load the full software stack installed by someone else, then
unload the package you want to work on.  Say that you are working on package
"desiblat":

    $>  module load desi
    $>  module unload desiblat

Now git clone desiblat somewhere and install it somewhere in your PATH / 
PYTHONPATH.

### I Already Installed Everything, but Now Want an Alternate Version of One Package

You can run desi_setup in "single package" mode.  See the subsection under
Installation.

### I Want to Install Everything, but with Custom Versions of Packages

No problem.  You should copy one of the text files in the "versions"
directory.  Name it something you like.  Now edit the versions of each package
that you want to install.  For example, you might start with a file that
has the latest stable tagged versions of all packages and change one or
more of the package versions to "master".  Now proceed with the installation
instructions below.

### I Want to Install Everything, but Using Different Dependencies

First, select / edit the text file of package versions you want.  Now decide
what commands you need to run inside a module file in order to load all the
python stack and other dependencies (e.g. CFITSIO, HARP, etc).  Paste those
commands in a text file.  Look in the modulefiles directory for example 
initialization commands used at NERSC.  Use this custom module init snippet
when running desi_setup below.  Now follow the installation instructions.


## Installation

Before installation, you will need to have all the external dependencies
installed on your system.  You also need to create / use a text file listing
the git branch/tag of each package.  Since we will be running many git
commands (when using the desi_source script), I highly recommend setting
up your ssh keys with a keychain, so that you don't have to type your
password dozens of times.  For example, at NERSC you can download this:

    http://www.funtoo.org/Keychain

and place the "keychain" shell script in your $PATH somewhere.  Then add
the lines:

    # start ssh keychain
    keystart () {
        eval `keychain --eval --agents ssh id_rsa`
    }

somewhere in your ~/.bashrc.ext.  Whenever you want to unlock your ssh
(probably once per session), just do "keystart".


### Dependencies

Get all the dependencies into your environment before using these tools.
At NERSC, you can load the "desi-conda" module.  On other systems, you 
will need a full python stack as well as some compiled packages (CFITSIO,
BOOST, LAPACK, mpi4py, HARP).


### Get the Source

Now make a working directory.  For this example, just put it in the top
of the desibuild source tree, but it could be anywhere.  We will use the
"desi_source" script and our text file of versions to get everything:

    $>  mkdir build
    $>  cd build
    $>  ../desi_source versions.txt

Where "versions.txt" is the file you have copied / modified that lists the
packages and their versions to install.  When this finishes, you should
have a git clone of every repo, and the working state inside each clone 
should be set to a local checkout of the specified branch/tag.

**NOTE:**  At this point you can go into those git clones and make new
branches, etc.  Whatever branch is checked out in each package is the one
that will be installed.  If you are working on multiple packages, just run
desi_source once with master.txt and then go create / checkout all the branches
you need across multiple packages!


### Installation Choices

Decide where you want to install things.  At NERSC, you should put everything
in your ${SCRATCH} directory somewhere for performance.  You can also install
software in two different configurations.  The default option installs all 
packages to versioned directories and creates modulefiles and shell files to 
load these into your environment.  Alternatively, you can install all 
packages to the same directory, overwriting any previous versions that exist.
This single-directory mode is useful for development versions of the software
or for installing into docker containers where only one version will be 
present.

If you are going to be using modules to load the installed software, determine any module commands needed to set up your dependencies.  Place
those commands into a small text file.  For NERSC systems, you should use one 
of the examples in the "modulefiles" directory unless you know what you are 
doing.  On a personal system or other HPC center, ensure that you know what 
module commands are needed to get the python stack and other dependencies into
your environment.


### Installing to Per-Package Directories

This is the default, and versions per-package subdirectories will be created underneath the prefix location.  This command will use the 
*current state* of all the git clones.  So if you made a local branch after 
getting the source with "desi_source", then that is what will be installed:

    $>  ../desi_setup \
        -p <prefix> \
        -v versions.txt \
        -e <my module snippet>

This installs everything.  If you don't use modules on your system (and 
therefore are managing your dependencies through other shell functions or
techniques), then you can just source the top-level "setup.sh" file that was
created in the installation prefix:

    $>  source <prefix>/setup.sh

Otherwise, you can now do:

    $>  module use <prefix>/modulefiles
    $>  module load desi

Where "prefix" is obviously what you specified with the "-p" option to 
desi_setup.  All DESI software is now ready to use.

### Installing to a Single Directory

### Install a Single Package

Imagine you have already installed all the packages you want, but now want 
to install an alternate version (like master) of a single package.  This is 
just a convenience.  Obviously you could just unload the module for the package 
you are testing, and then manually prepend to PATH and PYTHONPATH, etc.  
However, you can also use desi_setup in "single package mode".  First load 
your previous module stack to make sure any dependencies are loaded:

    $>  module load desi

Now go install a different version of one package:

    $>  ../desi_setup \
        -p <prefix> \
        -s <path/to/git/clone/desiblat>

In this example, we give the path to a clone of "desiblat" with the "-s" 
option.  This will infer the package name from the path (desiblat in this 
case).  It will then install the package to the prefix as usual.  It will 
**NOT** create a new desi module file, and will not create a new module 
version file.  You will have to manually swap/load this module file in order 
to use it.

### Set Default Versions

Just installing the packages and module files in the previous section does
*NOT* change the default versions of any module files.  Instead it creates
a temporary ".version" file that is ready to be moved into place.  To make
your freshly installed software the default just do:

    $>  ../desi_updatemod -p <prefix>

and now running "module avail" should reflect the change in the default
module versions.

