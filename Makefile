MAKEFILE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export BR2_EXTERNAL = $(MAKEFILE_DIR)

all:
	@cd buildroot && make all

.DEFAULT:
	@cd buildroot && make $@
