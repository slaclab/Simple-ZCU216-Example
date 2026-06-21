#!/bin/bash
set -e
####################################################

# Define the hardware type
# Note: Must match the axi-soc-ultra-plus-core/hardware directory name
hwType=XilinxZcu216

# Define number of DMA lanes
numLane=2

# Define number of DEST per DMA lane
#
# Soft default, NOT a hardware/driver limit: the DMA TDEST field is 8 bits
# (256 dest/lane) and the kernel driver supports far more. The practical ceiling
# is the on-board rogue TCP bridge's budget (~10 file descriptors + ~4 threads
# per numLane*numDest stream). axi-soc-ultra-plus-core/BuildYoctoProject.sh
# scales the systemd LimitNOFILE/LimitNPROC and kernel.threads-max with
# numLane*numDest, and the bridge initializes PyRFdc before the stream loop so
# libmetal's UIO fd stays below FD_SETSIZE (1024). High channel counts also need
# rxBuffCnt raised (shared RX pool). See ESROGUE-549.
#
# Note: the Xilinx meta-layer enables tcf-agent (TCP port 1534) by default. If it
# collides with your setup, disable it on the board: systemctl disable --now tcf-agent
numDest=32

# Define number of DMA TX/RX Buffers
rxBuffCnt=256
txBuffCnt=16

# Define DMA Buffer Size
buffSize=0x10000 # 64kB

####################################################

function show_help {
   echo "Usage: BuildYoctoProject.sh -f xsa [-c]"
   echo " -f xsa   - Path to XSA file"
   echo " -e       - Activate env and cd to build dir"
   echo " -c       - Force reconfigure"
   exit 1
}

while getopts "cef:h" flag
do
   case "${flag}" in
      f) file=${OPTARG};;
      c) EXTRA_ARGS="$EXTRA_ARGS -c";;
      e) EXTRA_ARGS="$EXTRA_ARGS -e";;
      h) show_help
   esac
done

if [ -z "${file}" ]
then
   show_help
fi

# Define the target name
xsaPath=$(realpath "${file}")

# Define the target name
targetName=${PWD##*/}

# Define the base dir
basePath=$(realpath "$PWD/../..")

# Make the build output
mkdir -p $basePath/build
mkdir -p $basePath/build/YoctoProjects
buildPath=$basePath/build/YoctoProjects

# Execute the common build Yocto project script
../../submodules/axi-soc-ultra-plus-core/BuildYoctoProject.sh \
-p $buildPath -n $targetName -x $xsaPath -h $hwType -T $basePath \
-l $numLane -d $numDest -t $txBuffCnt -r $rxBuffCnt -s $buffSize \
$EXTRA_ARGS
