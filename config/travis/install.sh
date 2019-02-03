#!/bin/bash
#
# Script to set up Travis-CI test VM.
#
# This file is generated by l2tdevtools update-dependencies.py any dependency
# related changes should be made in dependencies.ini.

L2TBINARIES_DEPENDENCIES="PyYAML backports.lzma dfdatetime dfvfs dfwinreg dtfabric libbde libewf libfsapfs libfsntfs libfvde libfwnt libfwsi libqcow libregf libsigscan libsmdev libsmraw libvhdi libvmdk libvshadow libvslvm pycrypto pysqlite pytsk3";

L2TBINARIES_TEST_DEPENDENCIES="funcsigs mock pbr six";

DPKG_PYTHON2_DEPENDENCIES="libbde-python libewf-python libfsapfs-python libfsntfs-python libfvde-python libfwnt-python libfwsi-python libqcow-python libregf-python libsigscan-python libsmdev-python libsmraw-python libvhdi-python libvmdk-python libvshadow-python libvslvm-python python-backports.lzma python-crypto python-dfdatetime python-dfvfs python-dfwinreg python-dtfabric python-pysqlite2 python-pytsk3 python-yaml";

DPKG_PYTHON2_TEST_DEPENDENCIES="python-coverage python-funcsigs python-mock python-pbr python-six python-tox";

DPKG_PYTHON3_DEPENDENCIES="libbde-python3 libewf-python3 libfsapfs-python3 libfsntfs-python3 libfvde-python3 libfwnt-python3 libfwsi-python3 libqcow-python3 libregf-python3 libsigscan-python3 libsmdev-python3 libsmraw-python3 libvhdi-python3 libvmdk-python3 libvshadow-python3 libvslvm-python3 python3-crypto python3-dfdatetime python3-dfvfs python3-dfwinreg python3-dtfabric python3-pytsk3 python3-yaml";

DPKG_PYTHON3_TEST_DEPENDENCIES="python3-mock python3-pbr python3-setuptools python3-six python3-tox";

RPM_PYTHON2_DEPENDENCIES="libbde-python2 libewf-python2 libfsapfs-python2 libfsntfs-python2 libfvde-python2 libfwnt-python2 libfwsi-python2 libqcow-python2 libregf-python2 libsigscan-python2 libsmdev-python2 libsmraw-python2 libvhdi-python2 libvmdk-python2 libvshadow-python2 libvslvm-python2 python2-backports-lzma python2-crypto python2-dfdatetime python2-dfvfs python2-dfwinreg python2-dtfabric python2-pysqlite python2-pytsk3 python2-pyyaml";

RPM_PYTHON2_TEST_DEPENDENCIES="python2-funcsigs python2-mock python2-pbr python2-six";

RPM_PYTHON3_DEPENDENCIES="libbde-python3 libewf-python3 libfsapfs-python3 libfsntfs-python3 libfvde-python3 libfwnt-python3 libfwsi-python3 libqcow-python3 libregf-python3 libsigscan-python3 libsmdev-python3 libsmraw-python3 libvhdi-python3 libvmdk-python3 libvshadow-python3 libvslvm-python3 python3-crypto python3-dfdatetime python3-dfvfs python3-dfwinreg python3-dtfabric python3-pytsk3 python3-pyyaml";

RPM_PYTHON3_TEST_DEPENDENCIES="python3-mock python3-pbr python3-six";

# Exit on error.
set -e;

if test ${TRAVIS_OS_NAME} = "osx";
then
	git clone https://github.com/log2timeline/l2tbinaries.git -b dev;

	mv l2tbinaries ../;

	for PACKAGE in ${L2TBINARIES_DEPENDENCIES};
	do
		echo "Installing: ${PACKAGE}";
		sudo /usr/bin/hdiutil attach ../l2tbinaries/macos/${PACKAGE}-*.dmg;
		sudo /usr/sbin/installer -target / -pkg /Volumes/${PACKAGE}-*.pkg/${PACKAGE}-*.pkg;
		sudo /usr/bin/hdiutil detach /Volumes/${PACKAGE}-*.pkg
	done

	for PACKAGE in ${L2TBINARIES_TEST_DEPENDENCIES};
	do
		echo "Installing: ${PACKAGE}";
		sudo /usr/bin/hdiutil attach ../l2tbinaries/macos/${PACKAGE}-*.dmg;
		sudo /usr/sbin/installer -target / -pkg /Volumes/${PACKAGE}-*.pkg/${PACKAGE}-*.pkg;
		sudo /usr/bin/hdiutil detach /Volumes/${PACKAGE}-*.pkg
	done

elif test -n "${FEDORA_VERSION}";
then
	CONTAINER_NAME="fedora${FEDORA_VERSION}";

	docker pull registry.fedoraproject.org/fedora:${FEDORA_VERSION};

	docker run --name=${CONTAINER_NAME} --detach -i registry.fedoraproject.org/fedora:${FEDORA_VERSION};

	docker exec ${CONTAINER_NAME} dnf install -y dnf-plugins-core;

	docker exec ${CONTAINER_NAME} dnf copr -y enable @gift/dev;

	if test ${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		docker exec ${CONTAINER_NAME} dnf install -y git python2 ${RPM_PYTHON2_DEPENDENCIES} ${RPM_PYTHON2_TEST_DEPENDENCIES};
	else
		docker exec ${CONTAINER_NAME} dnf install -y git python3 ${RPM_PYTHON3_DEPENDENCIES} ${RPM_PYTHON3_TEST_DEPENDENCIES};
	fi

elif test ${TRAVIS_OS_NAME} = "linux" && test ${TARGET} != "jenkins";
then
	sudo rm -f /etc/apt/sources.list.d/travis_ci_zeromq3-source.list;

	if test ${TARGET} = "pylint";
	then
		sudo add-apt-repository ppa:gift/pylint3 -y;
	fi

	sudo add-apt-repository ppa:gift/dev -y;
	sudo apt-get update -q;

	if test ${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		sudo apt-get install -y ${DPKG_PYTHON2_DEPENDENCIES} ${DPKG_PYTHON2_TEST_DEPENDENCIES};
	else
		sudo apt-get install -y ${DPKG_PYTHON3_DEPENDENCIES} ${DPKG_PYTHON3_TEST_DEPENDENCIES};
	fi
	if test ${TARGET} = "pylint";
	then
		sudo apt-get install -y pylint;
	fi
fi
