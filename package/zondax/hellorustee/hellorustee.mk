# reference: https://buildroot.org/downloads/manual/manual.html#_integration_of_cargo_based_packages
# to simplify the development workflow, we use a submodule

HELLORUSTEE_SITE=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/external/hello-rustee
HELLORUSTEE_SITE_METHOD=local

# get correct rust enviroment
HELLORUSTEE_DEPENDENCIES = host-python host-rustc optee-client optee-os
HELLORUSTEE_BIN_DIR = target/$(RUSTC_TARGET_NAME)/$(HELLORUSTEE_CARGO_MODE)
HELLORUSTEE_CARGO_OPTS = \
     $(if $(BR2_ENABLE_DEBUG),,--release) \
     --target=$(RUSTC_TARGET_NAME) #\
     #--manifest-path=$(@D)/Cargo.toml

HELLORUSTEE_OPTEE_CLIENT_EXPORT = $(STAGING_DIR_HOST)
HELLORUSTEE_TEEC_EXPORT = $(STAGING_DIR)
HELLORUSTEE_TA_DEV_KIT_DIR=$(STAGING_DIR)/optee/export-user_ta # This may change according to the target
HELLORUSTEE_HOST_CROSS_COMPILE=$(STAGING_DIR)
HELLORUSTEE_TA_CROSS_COMPILE=$(STAGING_DIR)
HELLORUSTT_TA=TEE
HELLORUSTEE_HOST=REE
HELLORUSTEE_SRC_=$(HELLORUSTEE_DIR)

HELLORUSTEE_CFLAGS 	= -Wall -I../../ta/src/include -I$(HELLORUSTEE_TEEC_EXPORT)/usr/include -I./include -fPIC
HELLORUSTEE_CFLAGS 	+= -I$(HELLORUSTEE_SRC_)/$(HELLORUSTEE_HOST)/lib/include



HELLORUSTEE_CARGO_ENV = CARGO_HOME=$(HOST_DIR)/share/cargo RUST_TARGET=$(RUSTC_TARGET_NAME) SRC_=$(HELLORUSTEE_DIR) OVERRIDE_SYSROOT=1 \
                        TEEC_EXPORT=$(STAGING_DIR) CROSS_COMPILE=$(TARGET_CROSS) TA_DEV_KIT_DIR=$(OPTEE_OS_SDK)  \

HELLORUSTEE_CONFIGURE_OPTS += CFLAGS="$(TARGET_CFLAGS) $(HELLORUSTEE_CFLAGS)"

ifeq ($(BR2_PACKAGE_HELLORUSTEE_SOMEOPTION),y)
# Add some more settings here
#HELLORUSTEE_DEPENDENCIES += readline
endif

#	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS)
define HELLORUSTEE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HELLORUSTEE_CARGO_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) $(HELLORUSTEE_CONFIGURE_OPTS) 
endef

define HELLORUSTEE_CONFIGURE_CMDS
    $(PYTHON) $(HELLORUSTEE_DIR)/framework/ta/src/newuuid.py
endef

define HELLORUSTEE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(HELLORUSTEE_DIR)/framework/host/src/hello-rustee $(TARGET_DIR)/usr/bin/hello-rustee
    $(INSTALL) -D -m 0444 $(HELLORUSTEE_DIR)/framework/ta/src/*.ta $(TARGET_DIR)/lib/optee_armtz
endef

# TODO: Start at bootime
# Slide 208

# Use generic package infrastructure
$(eval $(generic-package))
