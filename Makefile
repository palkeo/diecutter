# Makefile for development.
# See INSTALL and docs/dev.txt for details.
SHELL = /bin/bash
ROOT_DIR = $(shell pwd)
BIN_DIR = $(ROOT_DIR)/bin
DATA_DIR = $(ROOT_DIR)/var
WGET = wget
PYTHON = $(shell which python)
PROJECT = $(shell $(PYTHON) -c "import setup; print setup.NAME")
BUILDOUT_CFG = $(ROOT_DIR)/etc/buildout.cfg
BUILDOUT_DIR = $(ROOT_DIR)/lib/buildout
BUILDOUT_VERSION = 1.7.0
BUILDOUT_BOOTSTRAP_URL = https://raw.github.com/buildout/buildout/$(BUILDOUT_VERSION)/bootstrap/bootstrap.py
BUILDOUT_BOOTSTRAP = $(BUILDOUT_DIR)/bootstrap.py
BUILDOUT_BOOTSTRAP_ARGS = -c $(BUILDOUT_CFG) --version=$(BUILDOUT_VERSION) --distribute buildout:directory=$(ROOT_DIR)
BUILDOUT = $(BIN_DIR)/buildout
BUILDOUT_ARGS = -N -c $(BUILDOUT_CFG) buildout:directory=$(ROOT_DIR)
DIECUTTER_PUBLIC_API = http://diecutter.alwaysdata.net
NOSE = $(BIN_DIR)/nosetests


configure:
	mkdir -p $(ROOT_DIR)/etc
	wget -O etc/diecutter.ini --post-data "template_dir=$(ROOT_DIR)/demo/templates" $(DIECUTTER_PUBLIC_API)/diecutter.ini


develop: buildout


buildout:
	if [ ! -d $(BUILDOUT_DIR) ]; then mkdir -p $(BUILDOUT_DIR); fi
	if [ ! -f $(BUILDOUT_BOOTSTRAP) ]; then wget -O $(BUILDOUT_BOOTSTRAP) $(BUILDOUT_BOOTSTRAP_URL); fi
	if [ ! -x $(BUILDOUT) ]; then $(PYTHON) $(BUILDOUT_BOOTSTRAP) $(BUILDOUT_BOOTSTRAP_ARGS); fi
	$(BUILDOUT) $(BUILDOUT_ARGS)


clean:
	find $(ROOT_DIR)/ -name "*.pyc" -delete


distclean: clean
	rm -rf $(ROOT_DIR)/*.egg-info


maintainer-clean: distclean
	rm -rf $(BIN_DIR)/
	rm -rf $(ROOT_DIR)/lib/


serve:
	$(BIN_DIR)/pserve $(ROOT_DIR)/etc/diecutter.ini --reload


test: test-app test-documentation


test-app:
	$(NOSE) --config=etc/nose.cfg diecutter
	rm $(ROOT_DIR)/.coverage


test-documentation:
	$(NOSE) -c $(ROOT_DIR)/etc/nose.cfg sphinxcontrib.testbuild.tests


documentation: apidoc sphinx


# Remove auto-generated API documentation files.
# Files will be restored during sphinx-build, if "autosummary_generate" option
# is set to True in Sphinx configuration file.
apidoc-clean:
	find docs/api/ -type f \! -name "index.txt" -delete


apidoc: apidoc-clean
	$(BIN_DIR)/sphinx-apidoc --suffix txt --output-dir $(ROOT_DIR)/docs/api $(PROJECT)


sphinx:
	if [ ! -d docs/_static ]; then mkdir docs/_static; fi
	make --directory=docs clean html doctest


release:
	$(BIN_DIR)/fullrelease
