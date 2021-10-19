# arch64-efi32 ISO builder

This project allows for the creation of a bootable EFI-32 Archlinux x64 ISO
image. 

Useful for intel devices like the [LattePanda](http://www.lattepanda.com/).

# Dependencies

* Make
* Docker Engine

# Getting started

*For all of the following commands to work, you need to change to the root folder
of the project.*

Build a new Archlinux 2021.10.01 ISO with a efi32 loader using the `iso` task:

    make build runner TASK=iso ARCH_VERSION=2021.10.01

See [Makefile](Makefile) `task_` rules for other available tasks.

# Dev only

## Githooks

    git config core.hooksPath hooks