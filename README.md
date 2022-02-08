# Simple-ZCU216-Example

<!--- ######################################################## -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```bash
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```bash
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```bash
$ git-lfs version
git-lfs/2.1.1
```

<!--- ######################################################## -->

# Clone the GIT repository

```bash
$ git clone --recursive git@github.com:slaclab/Simple-ZCU216-Example
```

<!--- ######################################################## -->

# How to generate the RFSoC .BIT and .XSA files

1) Setup Xilinx licensing

```bash
$ source Simple-ZCU216-Example/firmware/vivado_setup.sh
```

2) Go to the target directory and make the firmware:

```bash
$ cd Simple-ZCU216-Example/firmware/targets/SimpleZcu216Example/
$ make
```

3) Optional: Review the results in GUI mode

```bash
$ make gui
```

The .bit and .XSA files are dumped into the SimpleZcu216Example/image directory:

```bash
$ ls -lath SimpleZcu216Example/images/
total 47M
drwxr-xr-x 5 ruckman re 2.0K Feb  7 07:13 ..
drwxr-xr-x 2 ruckman re 2.0K Feb  4 21:15 .
-rw-r--r-- 1 ruckman re  14M Feb  4 21:15 SimpleZcu216Example-0x01000000-20220204204648-ruckman-90df89c.xsa
-rw-r--r-- 1 ruckman re  33M Feb  4 21:14 SimpleZcu216Example-0x01000000-20220204204648-ruckman-90df89c.bit
```

<!--- ######################################################## -->

# How to build Petalinux images

1) Generate the .bit and .xsa files (refer to `How to generate the RFSoC .BIT and .XSA files` instructions).

2) Setup Xilinx licensing and petalinux software

```bash
$ source Simple-ZCU216-Example/firmware/vivado_setup.sh
$ source /u3/petalinux-v2021.2/settings.sh
```

3) Go to the target directory and run the `CreatePetalinuxProject.sh` script with arg pointing to path of .XSA file:

```bash
$ cd Simple-ZCU216-Example/firmware/targets/SimpleZcu216Example/
$ source CreatePetalinuxProject.sh images/SimpleZcu216Example-0x01000000-20220204204648-ruckman-90df89c.xsa
```

<!--- ######################################################## -->

# How to make the SD memory card for the first time

1) Creating Two Partitions.  Refer to URL below

https://xilinx-wiki.atlassian.net/wiki/x/EYMfAQ

2) Copy For the boot images, simply copy the files to the FAT partition.
This typically will include system.bit, BOOT.BIN, image.ub, and boot.scr.  Here's an example:

```bash
sudo mount /dev/sde1 /u1/boot
sudo cp /u1/ruckman/build/petalinux/SimpleZcu216Example/images/linux/system.bit /u1/boot/.
sudo cp /u1/ruckman/build/petalinux/SimpleZcu216Example/images/linux/BOOT.BIN   /u1/boot/.
sudo cp /u1/ruckman/build/petalinux/SimpleZcu216Example/images/linux/image.ub   /u1/boot/.
sudo cp /u1/ruckman/build/petalinux/SimpleZcu216Example/images/linux/boot.scr   /u1/boot/.
sudo umount /u1/boot
```

3) For the root file system, the process will depend on the format of your root file system image.

`roofts.ext4 -  This is an uncompressed ext4 file system image. To copy the contents to the root partition, you can use the following command: `

```bash
sudo dd if=/u1/ruckman/build/petalinux/SimpleZcu216Example/images/linux/rootfs.ext4 of=/dev/sde2
```

4) Power down the RFSoC board

5) Confirm the Mode SW2 [4:1] = 1110 (Mode Pins [3:0]). Note: Switch OFF = 1 = High; ON = 0 = Low.

6) Power up the RFSoC board

7) Confirm that you can ping the boot after it boots up

<!--- ######################################################## -->

# How to remote update the firmware bitstream

1) Using "scp" to copy your .bit file to the SD memory card on the RFSoC.  Here's an example:

```bash
scp Simple-ZCU216-Example/firmware/targets/SimpleZcu216Example/images/SimpleZcu216Example-0x01000000-20220204204648-ruckman-90df89c.bit root@10.0.0.200:/media/sd-mmcblk0p1/system.bit
```

2) Send a "sync" and "reboot" command to the RFSoC to load new firmware:  Here's an example:

```bash
ssh root@10.0.0.200 '/bin/sync; /sbin/reboot'
```

<!--- ######################################################## -->

# How to install the Rogue With Anaconda

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ######################################################## -->

# How to run the Rogue GUI

1) Go to software directory and setup the rogue environment

```bash
$ cd Simple-ZCU216-Example/software
$ source setup_env_slac.sh
```

2) Lauch the GUI:

```bash
$ python scripts/devGui
```

<!--- ######################################################## -->
