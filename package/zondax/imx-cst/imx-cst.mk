################################################################################
#
# imx-cst
#
################################################################################

# debian/3.3.1+dfsg-2
IMX_CST_SITE = https://gitlab.apertis.org/pkg/imx-code-signing-tool.git
IMX_CST_SITE_METHOD = git
IMX_CST_VERSION = e2c687a856e6670e753147aacef42d0a3c07891a
IMX_CST_LICENSE = BSD
IMX_CST_LICENSE_FILES = LICENSE.bsd3

HOST_IMX_CST_DEPENDENCIES = host-byacc host-flex host-openssl

define HOST_IMX_CST_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) $(HOST_CONFIGURE_OPTS) \
		OSTYPE=linux64 \
		ENCRYPTION=yes \
		COPTIONS="$(HOST_CFLAGS) $(HOST_CPPFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) -lcrypto" \
		PWD=$(@D)/code/cst \
		CC="$(CC) -I../../code/common/hdr \
			-I../../code/back_end/hdr \
			-I../../code/srktool/hdr \
			-I../../code/front_end/hdr \
			-I../../code/convlb/hdr" \
		LD=$(CC) \
		-C $(@D)/code/cst \
		build
	$(HOST_MAKE_ENV) $(MAKE) $(HOST_CONFIGURE_OPTS) \
		COPTS="$(HOST_CFLAGS) $(HOST_CPPFLAGS) $(HOST_LDFLAGS)" \
		-C $(@D)/code/hab_csf_parser
endef
define HOST_IMX_CST_INSTALL_CMDS
	$(INSTALL) -D -m 755 $(@D)/code/cst/code/obj.linux64/cst $(HOST_DIR)/bin/cst
	$(INSTALL) -D -m 755 $(@D)/code/cst/code/obj.linux64/srktool $(HOST_DIR)/bin/srktool
	$(INSTALL) -D -m 755 $(@D)/code/hab_csf_parser/csf_parser $(HOST_DIR)/bin/csf_parser
endef

$(eval $(host-generic-package))
