
iso_file="src/iso/archlinux-2017.05.01-x86_64.iso"

task_unpack() {
    if [ ! -f "$iso_file" ]; then
        runner_log_error "ISO file not found";
        exit 1;
    fi

    runner_log "Unpacking ISO image";

    filename=$(basename "$iso_file")
    filename="${filename%.*}"

    if [ ! -d "src/iso/$filename" ]; then
        mkdir -p "src/iso/$filename"; 
    fi

    bsdtar \
        -x \
        --exclude=isolinux/ \
        --exclude=EFI/archiso/ \
        --exclude=arch/boot/syslinux/ \
        -f "$iso_file" \
        -C "src/iso/$filename"

    runner_log "ISO image unpacked";
}
