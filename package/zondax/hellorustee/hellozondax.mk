# define variables here
HELLOZONDAX_VERSION=master
HELLOZONDAX_SITE_METHOD=git
HELLOZONDAX_SITE=https://github.com/Zondax/hello-rustee
HELLOZONDAX_LICENSE=Apache-2.0
LINUX_LICENSE_FILES=LICENSE

HELLOZONDAX_DEPENDENCIES=

ifeq ($(BR2_PACKAGE_HELLOZONDAX_SOMETHING),y)
# Add some more settings here
#HELLOZONDAX_DEPENDENCIES += readline
endif

# Or local
# HELLOZONDAX_SITE=../myapp
# HELLOZONDAX_SITE_METHOD=local

# Start at bootime
# Slide 208

# Use generic package infrastructure
$(eval $(generic-package))
