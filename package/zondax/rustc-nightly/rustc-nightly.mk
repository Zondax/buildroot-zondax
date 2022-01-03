################################################################################
#
# rustc
#
################################################################################

RUSTC_NIGHTLY_ARCH = $(call qstrip,$(BR2_PACKAGE_HOST_RUSTC_NIGHTLY_ARCH))
RUSTC_NIGHTLY_ABI = $(call qstrip,$(BR2_PACKAGE_HOST_RUSTC_NIGHTLY_ABI))

ifeq ($(BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS),y)
RUSTC_TARGET_NAME = $(RUSTC_NIGHTLY_ARCH)-unknown-linux-$(LIBC)$(RUSTC_NIGHTLY_ABI)
endif

ifeq ($(HOSTARCH),x86)
RUSTC_NIGHTLY_HOST_ARCH = i686
else
RUSTC_NIGHTLY_HOST_ARCH = $(HOSTARCH)
endif

RUSTC_HOST_NAME = $(RUSTC_NIGHTLY_HOST_ARCH)-unknown-linux-gnu

$(eval $(host-virtual-package))

ifeq ($(BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS),y)
define RUSTC_NIGHTLY_INSTALL_CARGO_CONFIG
	echo "************** INSTALLING CARGOOO **************"
	mkdir -p $(HOST_DIR)/share/cargo
	sed -e 's/@RUSTC_TARGET_NAME@/$(RUSTC_TARGET_NAME)/' \
		-e 's/@CROSS_PREFIX@/$(notdir $(TARGET_CROSS))/' \
	    ../package/zondax/rustc-nightly/cargo-config.in \
		> $(HOST_DIR)/share/cargo/config
endef
#package/rustc-nightly/cargo-config.in \
# check-package disable TypoInPackageVariable - TOOLCHAIN intended
TOOLCHAIN_POST_INSTALL_STAGING_HOOKS += RUSTC_NIGHTLY_INSTALL_CARGO_CONFIG
endif
