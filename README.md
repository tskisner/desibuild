# Scripts and Tools for Installation of DESI Software

For instructions on how to simply use conda packages built with 
desibuild, see the next section.  There are two different use cases 
that desibuild addresses:

1.  A DESI developer is working on multiple packages and
    is frustrated dealing with a dozen git repos.  desibuild
    makes it easy to checkout specific versions of all repos
    and build and install them.

2.  A DESI software maintainer wants to deploy conda packages
    and / or docker containers for use by DESI users.

## User Documentation

If you are a user that simply wants to make use of conda packages
built by others, first read the warnings below before following these
steps:

1.  Install Miniconda3 or a full Anaconda3 stack::

    https://conda.io/miniconda.html
    https://www.continuum.io/downloads

2.  Add the necessary channels to the top of the priority list::

        $> conda config --prepend channels astropy
        $> conda config --prepend channels tskisner

    verify the channel order::

        $> cat ~/.condarc
        channels:
          - tskisner
          - astropy
          - defaults

3.  Force use of python 3.5.  See warning below::

    $> conda install python=3.5

4.  Install desi packages::

    $> conda install desi

5.  Make sure to actually activate the conda root environment, 
    since that sets $DESIMODEL and eventually other environment
    variables::

        $> source activate

### Caveats / Warnings

**Beware**:

    - Installing these packages will download ~200MB of desimodel 
      data files (don't tether to your phone when doing this).

    - If you have an existing python3 anaconda installation, the 
      default python version is likely 3.6.  The DESI installation at 
      NERSC and these packages are using python 3.5.  We'll move to 3.6 
      soon after some more testing.  Installing these packages will 
      force you to use python 3.5.  You should create a new conda 
      environment for testing if you want to be sure not to break 
      something you already have.

    - (OS X) These packages will only work on the most recent version of 
      OS X, since that is the version on my build machine.

    - (Linux) These packages were built inside a CentOS-7 container, so
      should work on CentOS / RHEL 7 and newer, and should work on 
      Ubuntu 16.04 and newer (perhaps older depending on glibc versions).


## Individual Developer Tools

Imagine you are working on one or more DESI packages, and you need
specific versions of other DESI dependencies installed.

### Examples

Sometimes it is easiest to start with examples before going into all the
detailed options.

#### Example 1:  Latest Versions on a Personal Workstation

Assume that we have a shell command "desideps" that activates a conda
environment and loads the compiled DESI dependencies into our environment.
Also assume that we have a local copy of all the DESI auxiliary files (i.e.
the needed things found in $DESI_ROOT) in ~/desi.  We want to install the 
DESI tools to ~/software/desi, and we don't want to deal with modulefiles:

    $>  desideps
    $>  git clone https://github.com/tskisner/desibuild.git
    $>  ./desibuild/desi_source \
        --versions ./desibuild/systems/versions_master_https.txt
    $>  ./desibuild/desi_setup \
        --versions ./desibuild/systems/versions_master_https.txt \
        --prefix ~/software/desi \
        --common --desiroot ~/desi

This installs all tools to the same prefix, and there is a shell script
that we can source which loads this into our environment:

    $>  desideps
    $>  source ~/software/desi/setup.sh


#### Example 2:  Stable Versions at NERSC

For this example, we'll install stable versions of all the DESI packages
into our scratch directory on cori.nersc.gov.  We'll also override the basis
templates to point to the latest checkout of trunk.  We will use the desiconda
module installed by the DESI project to provide our dependencies:

    $>  module use /global/common/cori/contrib/desi/modulefiles
    $>  module load desiconda

Now get the source:

    $>  git clone https://github.com/tskisner/desibuild.git
    $>  ./desibuild/desi_source \
        --versions ./desibuild/systems/versions_stable_https.txt
    $>  ./desibuild/desi_setup \
        --versions ./desibuild/systems/versions_stable_https.txt \
        --prefix ${SCRATCH}/software/desi \
        --desiroot /project/projectdirs/desi \
        --basisdir spectro/templates/basis_templates/trunk \
        --init ./desibuild/systems/init.cori

The install prefix will now contain subdirectories for each package and version
as well as module files that we can load:

    $>  module use ${SCRATCH}/software/desi/modulefiles
    $>  module load desi


### Installation

Before installation, you will need to have all the external dependencies
installed on your system.  You also need to create / use a text file listing
the git branch/tag of each package.


#### Dependencies

Get all the dependencies into your environment before using these tools.
At NERSC, you can load the "desiconda" module.  On other systems, you 
will need a full python stack as well as some compiled packages (CFITSIO,
BOOST, LAPACK, mpi4py, HARP).


#### Get the Source

We need to decide where to put the git source trees for all the DESI
packages.  The default is to use the current working directory.  For this 
example, we'll run from a top-level directory that contains the desibuild
git clone.  We'll put all the source trees into a directory "desi_repos":

    $>  ./desibuild/desi_source \
    --versions ./desibuild/systems/versions_stable_https.txt \
    --gitdir ./desi_repos

This will create the directory passed in the "--gitdir" option and check out
all the desi git repos into that location.  The versions file contains the
list of packages, the git URL to use, and the git branch/tag to use.  When 
this finishes, you should have a git clone of every repo, and the working 
state inside each clone should be set to a local checkout of the specified 
branch/tag.

**NOTE:**  At this point you can go into those git clones and make new
branches, etc.  Whatever branch is checked out in each package is the one
that will be installed.  If you are working on multiple packages, just run
desi_source once and then go create / checkout all the branches you need 
across multiple packages.


#### Installation Choices

Decide where you want to install things.  At NERSC, you should put everything
in your ${SCRATCH} directory somewhere for performance.  You can also install
software in two different configurations.  The default option installs all 
packages to versioned directories and creates modulefiles and a shell file to 
load these into your environment.  Alternatively, you can install all 
packages to the same directory, overwriting any previous versions that exist.
This single-directory mode is useful for development versions of the software
or for installing into docker containers where only one version will be 
present.

If you are going to be using modules to load the installed software, 
determine any module commands needed to set up your dependencies.  Place
those commands into a small text file.  For NERSC systems, you should use one 
of the examples in the "systems/init.*" files unless you know what you are 
doing.  On a personal system or other HPC center, ensure that you know what 
module commands are needed to get the python stack and other dependencies into
your environment.


#### Installing to Per-Package Directories

This is the default, and versioned per-package subdirectories will be created 
underneath the prefix location.  This command will use the *current state* 
of all the git clones.  So if you made a local branch after getting the 
source with "desi_source", then that is what will be installed.  For this
example, assume we are installing in our scratch space on cori.nersc.gov:

    $>  ./desibuild/desi_setup \
    --versions ./desibuild/systems/versions_stable_https.txt \
    --gitdir ./desi_repos \
    --prefix ${SCRATCH}/software/desi \
    --desiroot /project/projectdirs/desi \
    --basisdir spectro/templates/basis_templates/trunk \
    --init ./desibuild/systems/init.cori

This installs everything.  You can load the latest versions of the tools into
your environment by directly source the shell snippet:

    $>  source ${SCRATCH}/software/desi/setup.sh

Or by loading the "desi" module:

    $>  module use ${SCRATCH}/software/desi/modulefiles
    $>  module load desi

Note that if you don't want to load the default version, you should manually
specify which version of the desi module you want to load.


#### Installing to a Single Directory

Sometimes it is useful to install all DESI packages to a single prefix, and
just have that one location in your environment.  This is particularly nice
when doing development and also when installing to a fixed docker image.

Simply pass the "--common" option to desi_setup.  The top-level setup.sh script
and the "desi" modulefile will be created, but per-package module files
obviously are redundant in this case.


#### Install a Single Package

Imagine you have already installed all the packages you want, but now want 
to install an alternate version (like master) of a single package.  In this 
case you can use desi_setup in "single package mode".  First load your 
previous module stack to make sure any dependencies are loaded:

    $>  module load desi

Now go install a different version of one package:

    $>  ./desibuild/desi_setup \
    --gitdir ./desi_repos \
    --prefix ${SCRATCH}/software/desi \
    --single desispec

This would install the current version of desispec into the prefix and also
make a module file.  You can then do:

    $>  module swap desispec desispec/<new version>

Single package installs do not change the top-level "desi" module files, so
you must manually swap in the alternate version of packages installed this
way.


#### Set Default Versions

Just installing the packages and module files in the previous section does
*NOT* change the default versions of any module files.  Instead it creates
a corresponding ".version" file for each package that can be symlinked to
the main .version file.  Given an install prefix, you can set the default
versions to those in a versions file:

    $>  ./desibuild/desi_defaults \
    --versions ./desibuild/systems/versions_stable_https.txt \
    --prefix ${SCRATCH}/software/desi

If you instead wanted to set the defaults to the current git repo versions
(because you had made new branches after running desi_source and before
installing), then just specify the location of the git repos to use for the
versions:

    $>  ./desibuild/desi_defaults \
    --versions ./desibuild/systems/versions_stable_https.txt \
    --prefix ${SCRATCH}/software/desi \
    --gitdir ./desi_repos

Now running "module avail" should reflect the change in the default module 
versions.


## Software Deployment Tools

These tools focus on a different problem.  Imagine you have a set of tagged versions of all packages, and you want to deploy them in a way
that they can be used by many people.


### Docker Images

If you want to build a docker image containing the DESI tools, see the 
README in the "systems" sub-directory.

### Conda Packages

If you want to build conda packages with the included "desi_condabuild"
script, you should be familiar with the conda-build process and also build
in an environment (a dedicated container) that is compatible with the conda
packages built by the desiconda tools.

