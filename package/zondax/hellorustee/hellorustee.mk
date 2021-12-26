# reference: https://buildroot.org/downloads/manual/manual.html#_integration_of_cargo_based_packages
# to simplify the development workflow, we use a submodule

HELLORUSTEE_SITE=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/external/hello-rustee
HELLORUSTEE_SITE_METHOD=local
HELLORUSTEE_DEPENDENCIES=

# get correct rust enviroment
HELLORUSTEE_DEPENDENCIES = host-rustc
HELLORUSTEE_CARGO_ENV = CARGO_HOME=$(HOST_DIR)/share/cargo
HELLORUSTEE_BIN_DIR = target/$(RUSTC_TARGET_NAME)/$(HELLORUSTEE_CARGO_MODE)
HELLORUSTEE_CARGO_OPTS = \
     $(if $(BR2_ENABLE_DEBUG),,--release) \
     --target=$(RUSTC_TARGET_NAME) \
     --manifest-path=$(@D)/Cargo.toml

ifeq ($(BR2_PACKAGE_HELLORUSTEE_SOMEOPTION),y)
# Add some more settings here
#HELLORUSTEE_DEPENDENCIES += readline
endif

#	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS)
define HELLORUSTEE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HELLORUSTEE_CARGO_ENV) cargo build $(HELLORUSTEE_CARGO_OPTS)
endef

define HELLORUSTEE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(HELLORUSTEE_DIR)/hello-rustee $(TARGET_DIR)/usr/bin/hello-rustee
endef

# TODO: Start at bootime
# Slide 208

# Use generic package infrastructure
$(eval $(generic-package))
