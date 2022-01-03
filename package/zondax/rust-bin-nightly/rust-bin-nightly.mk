################################################################################
#
# rust-bin
#
################################################################################
RUST_BIN_NIGHTLY_VERSION = 1.54.0
RUST_BIN_NIGHTLY_DATE = 2021-04-24
RUST_BIN_NIGHTLY_SITE = https://static.rust-lang.org/dist/$(RUST_BIN_NIGHTLY_DATE)
# example:
# https://static.rust-lang.org/dist/2021-04-24/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz
RUST_BIN_NIGHTLY_LICENSE = Apache-2.0 or MIT
RUST_BIN_NIGHTLY_LICENSE_FILES = LICENSE-APACHE LICENSE-MIT

HOST_RUST_BIN_NIGHTLY_PROVIDES = host-rustc-nightly

HOST_RUST_BIN_NIGHTLY_SOURCE = rust-nigthly-$(RUSTC_HOST_NAME).tar.xz

ifeq ($(BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS),y)
HOST_RUST_BIN_NIGHTLY_EXTRA_DOWNLOADS += rust-std-nigthly-$(RUSTC_TARGET_NAME).tar.xz
endif

HOST_RUST_BIN_NIGHTLY_LIBSTD_HOST_PREFIX = rust-std-nightly-$(RUSTC_NIGHTLY_HOST_NAME)

define HOST_RUST_BIN_NIGHTLY_LIBSTD_EXTRACT
	mkdir -p $(@D)/std
	$(foreach f,$(HOST_RUST_BIN_NIGHTLY_EXTRA_DOWNLOADS), \
		$(call suitable-extractor,$(f)) $(HOST_RUST_BIN_NIGHTLY_DL_DIR)/$(f) | \
			$(TAR) -C $(@D)/std $(TAR_OPTIONS) -
	)
	mkdir -p $(@D)/rustc/lib/rustlib/$(RUSTC_HOST_NAME)/lib
	cd $(@D)/rustc/lib/rustlib/$(RUSTC_HOST_NAME)/lib; \
		ln -sf ../../../../../$(HOST_RUST_BIN_NIGHTLY_LIBSTD_HOST_PREFIX)/lib/rustlib/$(RUSTC_HOST_NAME)/lib/* .
endef

HOST_RUST_BIN_NIGHTLY_POST_EXTRACT_HOOKS += HOST_RUST_BIN_NIGHTLY_LIBSTD_EXTRACT

HOST_RUST_BIN_NIGHTLY_INSTALL_COMMON_OPTS = \
	--prefix=$(HOST_DIR) \
	--disable-ldconfig

HOST_RUST_BIN_NIGHTLY_INSTALL_OPTS = \
	$(HOST_RUST_BIN_NIGHTLY_INSTALL_COMMON_OPTS) \
	--components=rustc,cargo,rust-std-$(RUSTC_NIGHTLY_HOST_NAME)

define HOST_RUST_BIN_NIGHTLY_INSTALL_RUSTC
	(cd $(@D); \
		./install.sh $(HOST_RUST_BIN_NIGHTLY_INSTALL_OPTS))
endef

ifeq ($(BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS),y)
define HOST_RUST_BIN_NIGHTLY_INSTALL_LIBSTD_TARGET
	(cd $(@D)/std/rust-std-$(RUST_BIN_NIGHTLY_DATE)-$(RUSTC_TARGET_NAME); \
		./install.sh $(HOST_RUST_BIN_NIGHTLY_INSTALL_COMMON_OPTS))
endef
endif

define HOST_RUST_BIN_NIGHTLY_INSTALL_CMDS
	$(HOST_RUST_BIN_NIGHTLY_INSTALL_RUSTC)
	$(HOST_RUST_BIN_NIGHTLY_INSTALL_LIBSTD_TARGET)
endef

HOST_RUST_BIN_NIGHTLY_POST_INSTALL_HOOKS += HOST_RUST_INSTALL_CARGO_CONFIG

$(eval $(host-generic-package))
