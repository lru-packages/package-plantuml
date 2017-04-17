NAME=plantuml
VERSION=2017.09
ITERATION=1.lru
PREFIX=/usr/local
LICENSE=BSD
VENDOR="Arnaud Roques"
MAINTAINER="Ryan Parman"
DESCRIPTION="PlantUML is used to draw UML diagram, using a simple and human readable text description. Diagrams are defined using a simple and intuitive language."
URL=http://plantuml.com
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean install-deps compile package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* plantuml/

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:

	yum -y install \
		ant \
		expat-devel \
		graphviz \
		java-1.8.0-oracle \
	;

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION)/usr/local/bin;
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION)/usr/local/share/plantuml;

	git clone -q -b v$(VERSION) https://github.com/plantuml/plantuml.git --depth=1 && \
	cd plantuml && \
		ant && \
		cp plantuml.jar /tmp/installdir-$(NAME)-$(VERSION)/usr/local/share/plantuml/plantuml.jar \
	;
	cp plantuml-bin /tmp/installdir-$(NAME)-$(VERSION)/usr/local/bin/plantuml;

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG.txt \
		--rpm-auto-add-directories \
		usr/local/bin \
		usr/local/share \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
