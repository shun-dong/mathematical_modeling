INSTALLING CHIRPLAB

1. INTRODUCTION

ChirpLab is a collection of Matlab and MEX routines which implements
a method for detecting quasi-periodic signals in noisy data via
chirplet path pursuit. The method is described in detail in [1].

2. INSTALLATION

2.1 Requirements

The software requirements for ChirpLab are

  - tar and gunzip to install the package on Unix-based systems, or zip to
    install the package on Windows.
  - Matlab version 6 or higher.

We have successfully compiled ChirpLab under the following operating systems
and compiler versions:

  - Solaris 9 (SunOS 5.9), cc 5.3
  - Fedora Core 4 Linux, gcc 3.3.6
  - Mac OS X

Compilation on other systems such as Windows should also work just fine.

2.2 Unpacking the archive

ChirpLab is distributed as a compressed tar or zip file. The current version
is available on the ChirpLab home page [2].

To install,

1) Download the compressed archive.

2) Uncompress it at the desired location:

    gunzip -c ChirpLab1_1.tar.gz | tar xfv -

or use zip if installing under Windows.

This will create a directory tree rooted at ChirpLab1_1/ containing
the source code.

3) Enter the ChirpLab directory:

    cd ChirpLab1_1

4a) Start up MATLAB and run ChirpPath. If the MEX source is not compiled, it
    will be compiled automatically.

4b) You may prefer to compile the MEX source outside MATLAB. To do so type
    "make" in the top ChirpLab directory:

    make

    If this returns errors make sure that your system fulfills the following
    requirements:
      - a C/C++ compiler capable of creating MEX files.
      - GNU make (compilation will not work using non-GNU versions of make).
        On Solaris, aliasing "make" to "gmake" will usually work.
    Some hand editing of the Makefile.include in the top level directory of ChirpLab 
    may be required to set the correct extension for compiled MEX files.

5) Before using ChirpLab, the Matlab paths must be set up. Edit the file
ChirpPath.m and change the variable CHIRPLABPATH to the directory where
ChirpLab is installed. Note that the directory separator character should
be the same as what is normally used on your OS.

(Optional) To permanently add the ChirpLab directories to your
MATLABPATH, you can add the following commands to your Unix profile
For csh-derived shells use:

setenv CHIRPLAB <root directory of ChirpLab>
setenv MATLABPATH ${MATLABPATH}:${CHIRPLAB}/mex/src/Networks:
${CHIRPLAB}/ChirpletTrans:${CHIRPLAB}/Data:${CHIRPLAB}/Data/ForDemos:
${CHIRPLAB}/Networks:${CHIRPLAB}/Utilities:${CHIRPLAB}/Inspiral

For Bourne-shell derived shells use:

CHIRPLAB=<root directory of ChirpLab>; export CHIRPLAB
MATLABPATH= ${MATLABPATH}:${CHIRPLAB}/mex/src/Networks:
${CHIRPLAB}/ChirpletTrans:${CHIRPLAB}/Data:${CHIRPLAB}/Data/ForDemos:
${CHIRPLAB}/Networks:${CHIRPLAB}/Utilities:${CHIRPLAB}/Inspiral

6) To test that ChirpLab is installed properly, start Matlab, set up the paths
using

    ChirpPath

and run the demo script

    FindBPDemo

3. PACKAGES

ChirpletTrans/  --  Functions for the Chirplet Transform.
Data/           --  Directory for storing data from simulations.
Demos/          --  Some examples of using the code.
Documentation/  --  Holds files with documentation for ChirpLab.
Networks/       --  Network flow algorithms for finding the minimum cost to
                    time ratio, shortest path and other related things.
                    Utilities/DisplayChirplets.m can be used to plot the
                    paths. Used for chirp detection
Inspiral/       --  Functions for generating simulated gravitational wave
                    signals.
Utilities/      --  Scripting utilities (for plotting chirplets etc.), code for
                    generating simulated noise and signals.

REFERENCES

[1] Emmanuel Candes, Philip Charlton and Hannes Helgason. "Detecting Highly
Oscillatory Signals by Chirplet Path Pursuit", http://arxiv.org/gr-qc/0604017

[2] http://www.chirplab.org
