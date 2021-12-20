MAKEFILE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export BR2_EXTERNAL = $(MAKEFILE_DIR)
IMAGES=$(MAKEFILE_DIR)/buildroot/output/images

all:
	@cd buildroot && make all

git-reset:
	@git submodule foreach --recursive git reset --hard
	@git submodule update --init --recursive

ccache-setup:
	@cd buildroot && make CCACHE_OPTIONS="--max-size=50G --zero-stats" ccache-options

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
	@cd buildroot && make $@
