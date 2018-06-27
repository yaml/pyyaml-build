.PHONY: default bootstrap update build build-linux build-windows

PYYAML_BRANCH := 4.1
LIBYAML_BRANCH := 0.2.1
VENV := source ./ansible/bin/activate

default:
	@echo "make bootstrap: bootstrap the build environment"
	@echo "make build: build linux and windows distributions"
	@echo "make clean: remove generated files"
	@echo "make destroy: delete build environment"

bootstrap: libyaml pyyaml ansible .vagrant/machines/linux/virtualbox/id .vagrant/machines/windows/virtualbox/id

libyaml:
	git clone --branch=$(LIBYAML_BRANCH) git@github.com:yaml/libyaml

pyyaml:
	git clone --branch=$(PYYAML_BRANCH) git@github.com:yaml/pyyaml

ansible:
	# virtualenv --system-site-packages ansible    # XXX --system-site-packages seemed not great idea
	virtualenv ansible
	($(VENV) pip install 'pyasn1>=0.1.8' 'pywinrm>=0.1.1' 'ansible>=2.1.0.0')

.vagrant/machines/linux/virtualbox/id:
	vagrant up linux
	($(VENV) ./install-linux.yml)
	vagrant halt linux

.vagrant/machines/windows/virtualbox/id:
	vagrant up windows
	($(VENV) ./install-windows.yml)
	vagrant halt windows

# update:
# 	hg -R libyaml pull -u
# 	hg -R pyyaml pull -u

build: update build-linux build-windows

build-linux:
	vagrant up linux
	($(VENV) ./build-linux.yml)
	vagrant halt linux

build-windows:
	vagrant up windows
	($(VENV) ./build-windows.yml)
	vagrant halt windows

clean:
	rm -rf dist *.retry

destroy:
	vagrant destroy -f linux
	vagrant destroy -f windows
	rm -rf .vagrant ansible pyyaml libyaml dist *.retry

