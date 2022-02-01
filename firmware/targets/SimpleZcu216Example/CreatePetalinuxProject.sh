#!/bin/sh

if [ $# -ne 1 ]
then
   echo "Usage: CreatePetalinuxProject.sh xsa"
   exit;
fi

# Define the hardware type
hwType=XilinxZcu208

# Make the build output
mkdir -p /u1/$USER
mkdir -p /u1/$USER/build
mkdir -p /u1/$USER/build/petalinux

# Execute the create petalinux script
../../submodules/axi-soc-ultra-plus-core/CreatePetalinuxProject.sh \
-p /u1/$USER/build/petalinux \
-n ${PWD##*/} \
-x $(realpath "${1}") \
-h $hwType \
-j 1
