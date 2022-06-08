################################################################################
#
# byacc
#
################################################################################

BYACC_SITE = https://invisible-mirror.net/archives/byacc
BYACC_VERSION = 20220128
BYACC_SOURCE = byacc-$(BYACC_VERSION).tgz
BYACC_LICENSE = Public Domain
BYACC_LICENSE_FILES = LICENSE

HOST_BYACC_CONF_OPTS = --program-transform-name='s,^,b,'

$(eval $(host-autotools-package))
