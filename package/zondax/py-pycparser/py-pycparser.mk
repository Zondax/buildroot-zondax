################################################################################
#
# python3-pycparser
#
################################################################################

# Please keep in sync with package/python-pycparser/python-pycparser.mk
PY_PYCPARSER_VERSION = 2.20
PY_PYCPARSER_SOURCE = pycparser-$(PY_PYCPARSER_VERSION).tar.gz
PY_PYCPARSER_SITE = https://files.pythonhosted.org/packages/0f/86/e19659527668d70be91d0369aeaa055b4eb396b0f387a4f92293a20035bd
PY_PYCPARSER_SETUP_TYPE = setuptools
PY_PYCPARSER_LICENSE = BSD-3-Clause
PY_PYCPARSER_LICENSE_FILES = LICENSE
HOST_PY_PYCPARSER_DL_SUBDIR = py-pycparser
HOST_PY_PYCPARSER_NEEDS_HOST_PYTHON = python3

$(eval $(host-python-package))
