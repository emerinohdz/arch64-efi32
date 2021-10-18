SRC_VOLUME_MOUNT ?= $(shell pwd)
ARCH_VERSION ?= 2021.10.01
OUTPUT_ISO ?= target/arch64-efi32.iso

UID := $(shell id -u)
GID := $(shell id -g)
CONTAINER_IMAGE := arch64-efi32:latest
ARCH_ISO_NAME := archlinux-$(ARCH_VERSION)-x86_64
ARCH_ISO_URL := http://il.us.mirror.archlinux-br.org/iso/$(ARCH_VERSION)/$(ARCH_ISO_NAME).iso
ARCH_ISO_PATH := download/$(ARCH_ISO_NAME).iso
ARCH_EXTRACTED_PATH := target/iso/$(ARCH_ISO_NAME)
EFI32_PATH := target/bootia32.efi
EFIBOOT_IMG_PATH := target/efiboot.img

define docker_run
	docker run --rm \
		-v $(SRC_VOLUME_MOUNT):/project -w /project \
		-it \
		--entrypoint $1 \
		$(CONTAINER_IMAGE) \
		$2
endef

lint-dockerfile: # Dockerfile linting
	docker run --rm -i -v $(SRC_VOLUME_MOUNT):/project -w /project ghcr.io/hadolint/hadolint < Dockerfile

build: # build docker image
	docker build --build-arg UID=$(UID) --build-arg GID=$(GID) . -t $(CONTAINER_IMAGE)

shell: # debugging shell
	$(call docker_run,bash,)

runner: # execute tasks using the container
	$(call docker_run,make,task_$(TASK))

clean:
	chmod -R 777 target/iso
	rm -rf target/

task_get_iso: $(ARCH_ISO_PATH)

$(ARCH_ISO_PATH):
	mkdir -p download
	cd download && wget $(ARCH_ISO_URL)

task_unpack: $(ARCH_EXTRACTED_PATH)

$(ARCH_EXTRACTED_PATH): $(ARCH_ISO_PATH)
	mkdir -p $(ARCH_EXTRACTED_PATH)
	bsdtar -x -f $(ARCH_ISO_PATH) -C $(ARCH_EXTRACTED_PATH)

task_efi32loader: $(EFIBOOT_IMG_PATH)

$(EFIBOOT_IMG_PATH): $(EFI32_PATH) $(ARCH_EXTRACTED_PATH)
	skip=$$(fdisk -l $(ARCH_ISO_PATH) | grep EFI | awk '{print $$2}'); \
	count=$$(fdisk -l $(ARCH_ISO_PATH) | grep EFI | awk '{print $$4}'); \
	dd if="$(ARCH_ISO_PATH)" bs=512 skip="$$skip" count="$$count" of="$(EFIBOOT_IMG_PATH).orig"

	chmod +w "$(ARCH_EXTRACTED_PATH)/EFI/BOOT"
	install -m 0444 "$(EFI32_PATH)" "$(ARCH_EXTRACTED_PATH)/EFI/BOOT/"
	chmod -w "$(ARCH_EXTRACTED_PATH)/EFI/BOOT"

    # cannot directly copy files with mcopy, throws 'Disk full' error
	rm -rf target/efiboot && mkdir target/efiboot
	mcopy -s -p -D o -i "$(EFIBOOT_IMG_PATH).orig" :: target/efiboot/
	cp "$(EFI32_PATH)" target/efiboot/EFI/BOOT/
    # TODO: calculate correct size
	rm -f $(EFIBOOT_IMG_PATH) && mkfs.fat -C -n ARCHISO_EFI "$(EFIBOOT_IMG_PATH)" 102400
	mcopy -s -p -D o -i "$(EFIBOOT_IMG_PATH)" target/efiboot/* ::

$(EFI32_PATH): assets/grub.cfg
	mkdir -p target
	grub-mkstandalone \
		-d /usr/lib/grub/i386-efi/ \
		-O i386-efi \
		--modules="part_gpt part_msdos" \
		--fonts="unicode" \
		--themes="" \
		-o "$(EFI32_PATH)" \
		"boot/grub/grub.cfg=assets/grub.cfg";

task_dist: $(OUTPUT_ISO)

$(OUTPUT_ISO): $(ARCH_EXTRACTED_PATH) $(EFIBOOT_IMG_PATH) 
    # see https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/archiso/mkarchiso
	xorriso -as mkisofs \
		-iso-level 3 \
		-full-iso9660-filenames \
		-joliet \
		-joliet-long \
		-rational-rock \
		-volid "ARCH64_EFI32" \
		-isohybrid-mbr "$(ARCH_EXTRACTED_PATH)/syslinux/isohdpfx.bin" \
		--mbr-force-bootable \
		-partition_offset 16 \
		-eltorito-boot syslinux/isolinux.bin \
		-eltorito-catalog syslinux/boot.cat \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		-append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B "$(EFIBOOT_IMG_PATH)" \
		-appended_part_as_gpt \
		-eltorito-alt-boot \
		-output $(OUTPUT_ISO) \
		$(ARCH_EXTRACTED_PATH)