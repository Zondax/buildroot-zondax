# reference: https://buildroot.org/downloads/manual/manual.html#_integration_of_cargo_based_packages
# to simplify the development workflow, we use a submodule

TEE_SERVICE_SITE=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/external/tee-service
TEE_SERVICE_SITE_METHOD=local

# get correct rust enviroment
TEE_SERVICE_DEPENDENCIES = host-python host-rustc-nightly optee-client optee-os
TEE_SERVICE_BIN_DIR = target/$(RUSTC_TARGET_NAME)/$(TEE_SERVICE_CARGO_MODE)
TEE_SERVICE_CARGO_OPTS = \
     $(if $(BR2_ENABLE_DEBUG),,--release) \
     --target=$(RUSTC_TARGET_NAME)

TEE_SERVICE_TA=TEE
TEE_SERVICE_HOST=REE
TEE_SERVICE_FRAMEWORK_TA_INCLUDE=$(TEE_SERVICE_DIR)/framework/ta/src/include

TEE_SERVICE_CFLAGS 	= -Wall -I$(TEE_SERVICE_DIR)/$(TEE_SERVICE_TA)/lib/include -I$(TEE_SERVICE_FRAMEWORK_TA_INCLUDE) -I$(STAGING_DIR)/usr/include -I./include -fPIC
TEE_SERVICE_CFLAGS 	+= -I$(TEE_SERVICE_DIR)/$(TEE_SERVICE_HOST)/lib/include

TEE_SERVICE_ENV = CARGO_HOME=$(HOST_DIR)/share/cargo RUST_TARGET=$(RUSTC_TARGET_NAME) SRC_=$(TEE_SERVICE_DIR) OVERRIDE_SYSROOT=1 \
                        TEEC_EXPORT=$(STAGING_DIR) CROSS_COMPILE=$(TARGET_CROSS) TA_DEV_KIT_DIR=$(OPTEE_OS_SDK)  \
						TA_CROSS_COMPILE=$(TARGET_CROSS)

TEE_SERVICE_CONFIGURE_OPTS += CFLAGS="$(TARGET_CFLAGS) $(TEE_SERVICE_CFLAGS)"

ifeq ($(BR2_PACKAGE_TEE_SERVICE_SOMEOPTION),y)
# Add some more settings here
#TEE_SERVICE_DEPENDENCIES += readline
endif

define TEE_SERVICE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TEE_SERVICE_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) $(TEE_SERVICE_CONFIGURE_OPTS)
endef

define TEE_SERVICE_CONFIGURE_CMDS
    $(PYTHON) $(TEE_SERVICE_DIR)/framework/ta/src/newuuid.py
endef

define TEE_SERVICE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(TEE_SERVICE_DIR)/framework/host/src/rustee_app $(TARGET_DIR)/sbin/tee-substrate-service
    $(INSTALL) -D -m 0444 $(TEE_SERVICE_DIR)/framework/ta/src/*.ta $(TARGET_DIR)/lib/optee_armtz
endef

# Use generic package infrastructure
$(eval $(generic-package))
