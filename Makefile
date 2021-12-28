MAKEFILE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export BR2_EXTERNAL = $(MAKEFILE_DIR)
BUILDROOT_DIR=$(MAKEFILE_DIR)/buildroot

ifeq ($(BUILDROOT), st)
	BUILDROOT_DIR=$(MAKEFILE_DIR)/buildroot-st
endif

IMAGES=$(BUILDROOT_DIR)/output/images

all:image_dir
	@cd $(BUILDROOT_DIR) && make all

image_dir:
	@ln -sfT $(IMAGES) $(MAKEFILE_DIR)/images

git-reset:
	@git submodule foreach --recursive git reset --hard
	@git submodule update --init --recursive

ccache-setup:
	@cd $(BUILDROOT_DIR) && make CCACHE_OPTIONS="--max-size=50G --zero-stats" ccache-options

# To exit QEMU use ctrl-a + X
start-qemu-host:
	@cd $(IMAGES) && ../host/bin/qemu-system-arm \
	-machine virt -machine secure=on -cpu cortex-a15 \
	-smp 1 -s -m 1024 -d unimp \
	-serial mon:stdio \
	-netdev user,id=vmnic -device virtio-net-device,netdev=vmnic \
	-semihosting-config enable,target=native \
	-bios flash.bin

.DEFAULT:
	@cd $(BUILDROOT_DIR) && make $@
