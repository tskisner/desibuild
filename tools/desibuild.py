# Utility functions used by the desibuild scripts.

from __future__ import (absolute_import, division, print_function, 
    unicode_literals)

import sys
import os
import re
import subprocess as sp
import shutil
import stat

from hashlib import md5


class clr:
    DEFAULT = "\033[39m"
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    LGRAY = "\033[37m"
    DGRAY = "\033[90m"
    LRED = "\033[91m"
    LGREEN = "\033[92m"
    LYELLOW = "\033[93m"
    LBLUE = "\033[94m"
    LMAGENTA = "\033[95m"
    LCYAN = "\033[96m"
    WHITE = "\033[97m"
    ENDC = "\033[0m"
    def disable(self):
        DEFAULT = ""
        BLACK = ""
        RED = ""
        GREEN = ""
        YELLOW = ""
        BLUE = ""
        MAGENTA = ""
        CYAN = ""
        LGRAY = ""
        DGRAY = ""
        LRED = ""
        LGREEN = ""
        LYELLOW = ""
        LBLUE = ""
        LMAGENTA = ""
        LCYAN = ""
        WHITE = ""
        ENDC = ""


def pyversion():
    major = sys.version_info[0]
    minor = sys.version_info[1]
    return "{}.{}".format(major, minor)


def sprun(com):
    p = sp.Popen(com, stdout=sp.PIPE, stderr=sp.PIPE, universal_newlines=True)
    out, err = p.communicate()
    return out.splitlines(), err.splitlines()


def copy_scripts(source, dest):
    scriptmod = (stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR
                | stat.S_IRGRP | stat.S_IWGRP | stat.S_IXGRP
                | stat.S_IROTH | stat.S_IXOTH)
    names = os.listdir(source)
    for name in names:
        src = os.path.join(source, name)
        dst = os.path.join(dest, name)
        if os.path.isfile(dst):
            os.remove(dst)
        shutil.copy2(src, dst)
        os.chmod(dst, scriptmod)
    return


def load_versions(path):
    pkgs = []
    with open(path, "r") as f:
        for line in f:
            if not re.match(r"^#.*", line):
                cols = line.split()
                if len(cols) == 3:
                    props = {}
                    props["name"] = cols[0]
                    props["url"] = cols[1]
                    props["version"] = cols[2]
                    pkgs.append(props)
    return pkgs


def modify_env(envset, envprepend):
    for t in envset:
        os.environ[t[0]] = t[1]
    for t in envprepend:
        cur = os.environ[t[0]]
        new = None
        if cur != "":
            new = "{}:{}".format(t[1], cur)
        else:
            new = "{}".format(t[1])
        os.environ[t[0]] = new
    return


def git_version():
    com = ["git", "branch", "--list"]
    allbranch, err = sprun(com)
    ver = None
    for b in allbranch:
        mat = re.match(r"[\*]\s+(.*)", b)
        if mat is not None:
            br = mat.group(1)
            ver = re.sub(r"work-", "", br)
    return ver


def build_version(scriptdir):
    # Get git version of desibuild
    here = os.path.abspath(os.getcwd())
    os.chdir(scriptdir)

    com = ["git", "describe", "--tags", "--dirty", "--always"]
    out, err = sprun(com)
    desc = out[0].split("-")

    buildver = None
    if len(desc) == 1:
        # we are at a tag
        buildver = desc[0]
    else:
        com = ["git", "rev-list", "--count", "HEAD"]
        out, err = sprun(com)
        cnt = out[0]
        buildver = "{}.dev{}".format(desc[0], cnt)

    os.chdir(here)
    return buildver


def desi_version(buildver, depstr):
    dephash = md5(depstr.encode(encoding="ascii")).hexdigest()[:6]
    #datestr = time.strftime("%Y%m%d", time.localtime(time.time()))
    return "{}-{}".format(buildver, dephash)

