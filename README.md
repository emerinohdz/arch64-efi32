# arch64-efi32 ISO builder

This project allows for the creation of a bootable EFI-32 Archlinux x64 ISO
image. 

Useful for intel devices like the LattePanda.

# Dependencies

* NPM is needed to download the [bash-task-runner](https://github.com/stylemistake/bash-task-runner).
* A working GNU/Linux environment, with grub and bsdtar packages installed.

# Getting started

To build a new ISO, you'll need to first install the bash-task-runner:

    npm install

Then, you can simply call the runner to generate the ISO:

    node_modules/bash-task-runner/bin/runner

There are other tasks available, you can first unpack the ISO 
(to include modules, for instance), and then repackage it:

    node_modules/bash-task-runner/bin/runner unpack
    // modify ISO contents as needed
    node_modules/bash-task-runner/bin/runner pack
