################################################################################
#
# python3-six
#
################################################################################

# Please keep in sync with package/python-six/python-six.mk
PY_SIX_VERSION = 1.16.0
PY_SIX_SOURCE = six-$(PY_SIX_VERSION).tar.gz
PY_SIX_SITE = https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e
PY_SIX_SETUP_TYPE = setuptools
PY_SIX_LICENSE = MIT
PY_SIX_LICENSE_FILES = LICENSE
HOST_PY_SIX_DL_SUBDIR = py-six
HOST_PY_SIX_NEEDS_HOST_PYTHON = python3

$(eval $(host-python-package))
