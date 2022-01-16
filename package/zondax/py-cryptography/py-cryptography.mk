################################################################################
#
# py-cryptography
# a simple copy of the recet pyhon-cryptography
#
################################################################################

PY_CRYPTOGRAPHY_VERSION = 3.3.2
PY_CRYPTOGRAPHY_SOURCE = cryptography-$(PY_CRYPTOGRAPHY_VERSION).tar.gz
PY_CRYPTOGRAPHY_SITE = https://files.pythonhosted.org/packages/d4/85/38715448253404186029c575d559879912eb8a1c5d16ad9f25d35f7c4f4c
PY_CRYPTOGRAPHY_SETUP_TYPE = setuptools
PY_CRYPTOGRAPHY_LICENSE = Apache-2.0 or BSD-3-Clause
PY_CRYPTOGRAPHY_LICENSE_FILES = LICENSE LICENSE.APACHE LICENSE.BSD
PY_CRYPTOGRAPHY_CPE_ID_VENDOR = cryptography_project
PY_CRYPTOGRAPHY_CPE_ID_PRODUCT = cryptography
#PY_CRYPTOGRAPHY_DEPENDENCIES = host-python-cffi openssl
#PY_CRYPTOGRAPHY_DEPENDENCIES = host-py-cffi openssl
HOST_PY_CRYPTOGRAPHY_NEEDS_HOST_PYTHON = python3
HOST_PY_CRYPTOGRAPHY_DEPENDENCIES = \
	host-py-cffi \
	host-py-six \
	host-openssl \

$(eval $(python-package))
$(eval $(host-python-package))
