# define variables here
# HELLORUSTEE_VERSION=master
# HELLORUSTEE_SITE_METHOD=git
# HELLORUSTEE_SITE=https://github.com/Zondax/hello-rustee
# HELLORUSTEE_LICENSE=Apache-2.0
# LINUX_LICENSE_FILES=LICENSE

HELLORUSTEE_SITE=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/external/hello-rustee
HELLORUSTEE_SITE_METHOD=local
HELLORUSTEE_DEPENDENCIES=

ifeq ($(BR2_PACKAGE_HELLOZONDAX_SOMETHING),y)
# Add some more settings here
#HELLORUSTEE_DEPENDENCIES += readline
endif

# Start at bootime
# Slide 208

#	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS)
define HELLORUSTEE_BUILD_CMDS
	$(MAKE) -C $(@D)
endef

define HELLORUSTEE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(HELLORUSTEE_DIR)/hello-rustee $(TARGET_DIR)/usr/bin/hello-rustee
endef

# Use generic package infrastructure
$(eval $(generic-package))
