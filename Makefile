MAKEFILE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export BR2_EXTERNAL = $(MAKEFILE_DIR)

all:
	@cd buildroot && make all

ccache-setup:
	@cd buildroot && make CCACHE_OPTIONS="--max-size=50G --zero-stats" ccache-options

.DEFAULT:
	@cd buildroot && make $@
