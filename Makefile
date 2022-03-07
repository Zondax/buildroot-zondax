DOCKER_APP_SRC=/project


INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
USERID:=$(shell id -u)
$(info USERID                : $(USERID))

DOCKER_IMAGE=zondax/builder-yocto:latest

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	NPROC=$(shell nproc)
endif
ifeq ($(UNAME_S),Darwin)
	NPROC=$(shell sysctl -n hw.physicalcpu)
endif

define run_docker
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	-u $(USERID) \
	-v $(shell pwd):/project \
	$(DOCKER_IMAGE) "$(1)"
endef


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

.PHONY: docker
docker:
	docker pull $(DOCKER_IMAGE)

dk2:docker
	$(call run_docker, BUILDROOT=st make -C $(DOCKER_APP_SRC) zondaxtee_stm32mp157_dk2_defconfig)
	$(call run_docker, make -C $(DOCKER_APP_SRC))

imx8mmevk:docker
	$(call run_docker, BUILDROOT=st make -C $(DOCKER_APP_SRC) make zondaxtee_imx8mmevk_defconfig)
	$(call run_docker, BUILDROOT=st make -C $(DOCKER_APP_SRC))

.DEFAULT:
	@cd $(BUILDROOT_DIR) && make $@
