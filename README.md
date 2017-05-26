# arch64-efi32 ISO builder

This project allows for the creation of a bootable EFI-32 Archlinux x64 ISO
image. 

Useful for intel devices like the [LattePanda](http://www.lattepanda.com/).

# Dependencies

* NPM: Needed to download the [bash-task-runner](https://github.com/stylemistake/bash-task-runner).
* GRUB 2 (i386-efi): Creates the EFI 32 bootloader.
* bsdtar: Used to unpack the ISO image.
* cdrtools: Used to generate de ISO image.
* libisoburn: Needed to create bootable USB images (xorriso).

# Getting started

*For all of the following commands to work, you need to change to the root folder
of the project.*

To build a new ISO, you'll need to first install the bash-task-runner:

    npm install

Then, you can simply call the runnerfile.sh script to generate the ISO:

    ./runnerfile.sh 

There are other tasks available, you can first unpack the ISO 
(to include modules, for instance), and then repackage it:

    ./runnerfile.sh unpack
    // modify ISO contents as needed
    ./runnerfile.sh build dist
