.PHONY: default bootstrap update build build-linux build-windows

default:
	@echo "make bootstrap: bootstrap the build environment"
	@echo "make build: build linux and windows distributions"
	@echo "make clean: remove generated files"
	@echo "make destroy: delete build environment"

bootstrap: libyaml pyyaml ansible .vagrant/machines/linux/virtualbox/id .vagrant/machines/windows/virtualbox/id

libyaml:
	hg clone ssh://hg@bitbucket.org/xi/libyaml

pyyaml:
	hg clone ssh://hg@bitbucket.org/xi/pyyaml

ansible:
	virtualenv --system-site-packages ansible
	./ansible/bin/pip install 'pyasn1>=0.1.8' 'pywinrm>=0.1.1' 'ansible>=2.1.0.0'

.vagrant/machines/linux/virtualbox/id:
	vagrant up linux
	./install-linux.yml
	vagrant halt linux

.vagrant/machines/windows/virtualbox/id:
	vagrant up windows
	./install-windows.yml
	vagrant halt windows

update:
	hg -R libyaml pull -u
	hg -R pyyaml pull -u

build: update build-linux build-windows

build-linux:
	vagrant up linux
	./build-linux.yml
	vagrant halt linux

build-windows:
	vagrant up windows
	./build-windows.yml
	vagrant halt windows

clean:
	rm -rf dist *.retry

destroy:
	vagrant destroy -f linux
	vagrant destroy -f windows
	rm -rf .vagrant ansible pyyaml libyaml dist *.retry

