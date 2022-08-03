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

all: image_dir
	@cd $(BUILDROOT_DIR) && make all

image_dir:
	@ln -sfT $(IMAGES) $(MAKEFILE_DIR)/images

git-reset:
	@git submodule foreach --recursive git reset --hard
	@git submodule update --init --recursive

ccache-setup:
	@cd $(BUILDROOT_DIR) && make CCACHE_OPTIONS="--max-size=50G --zero-stats" ccache-options

# To exit QEMU use ctrl-a + X
# Parameters: https://www.qemu.org/docs/master/system/invocation.html
# some important ones:
# -s ( enabled GDB in port 1234)
# -S ( do not start automatically )
# -device virtio-9p-device,fsdev=fsdev0,mount_tag=host \
# -fsdev local,id=fsdev0,security_model=none,path=${VIRTFS_DIR}
VIRTFS_DIR=$(BUILDROOT_DIR)buildroot/output/build

start-qemu-host:
	cd $(IMAGES) && ../host/bin/qemu-system-arm \
	-semihosting-config enable=on,target=native \
	-s \
	-machine virt,secure=on \
	-cpu cortex-a15 \
	-bios flash.bin \
	-m 1G \
	-smp 1 \
	-d unimp \
	-serial mon:stdio \
	-serial telnet:0.0.0.0:54321,server,nowait \
	-object rng-random,filename=/dev/urandom,id=rng0 \
	-device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
	-device virtio-net-device,netdev=vmnic \
	-netdev user,id=vmnic 

.PHONY: docker
docker:
	docker pull $(DOCKER_IMAGE)

dk2:docker
	$(call run_docker, BUILDROOT=st make -C $(DOCKER_APP_SRC) zondaxtee_stm32mp157_dk2_defconfig)
	$(call run_docker, BUILDROOT=st make -C $(DOCKER_APP_SRC))

imx8mmevk:docker
	$(call run_docker, BUILDROOT=0 make -C $(DOCKER_APP_SRC) zondaxtee_imx8mmevk_defconfig)
	$(call run_docker, BUILDROOT=0 make -C $(DOCKER_APP_SRC))

#------------------------------------
# Key generation scripts

# generates OPTEE keys (used to sign TAs)
genkeys-optee:
	@./tools/optee/gen_keys.sh
.PHONY: genkeys-optee

# generates uboot keys
genkeys-uboot:
	@./tools/uboot/gen_keys.sh
.PHONY: genkeys-uboot

# generate 
genkeys-dk2:
	@./tools/dk2/generate_keys.sh
.PHONY: genkeys-dk2

genkeys: genkeys-optee genkeys-uboot genkeys-dk2 showkeys
	@echo "Keys have been generated!"
.PHONY: genkeys

# show the location of the keys
showkeys:
	@printf "\n\e[1;34m OPTEE KEYS ---------------------------------------\e[0m\n"
	@ls -l keys/optee_keys/

	@printf "\n\e[1;34m UBOOT KEYS ---------------------------------------\e[0m\n"
	@ls -l keys/uboot_keys/

	@printf "\n\e[1;34m TFA KEYS   ---------------------------------------\e[0m\n"
	@ls -l keys/tfa_keys/
.PHONY: showkeys

.DEFAULT:
	@cd $(BUILDROOT_DIR) && make $@
