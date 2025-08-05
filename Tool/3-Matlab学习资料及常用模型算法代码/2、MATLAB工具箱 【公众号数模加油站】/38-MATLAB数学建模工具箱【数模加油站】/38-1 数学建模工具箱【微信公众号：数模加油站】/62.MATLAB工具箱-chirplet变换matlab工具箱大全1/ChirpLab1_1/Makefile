include Makefile.include

VERSION = 1_1
TARGETS = 
SUBDIRS = foo Documentation mex
INCLUDE_FILE = FORRELEASE.txt

all : $(TARGETS)
	for d in $(SUBDIRS); do \
		(if [ -d $$d ]; then cd $$d && ${MAKE} all; fi); \
	done

distTar :
	cd .. && \
	$(TAR) cf - -I ChirpLab$(VERSION)/FORRELEASE.txt \
          | gzip > ChirpLab$(VERSION)/ChirpLab$(VERSION).tar.gz

distTarMacOSX :
	cd .. && \
	$(TAR) cf - --files-from=ChirpLab$(VERSION)/FORRELEASE.txt \
          | gzip > ChirpLab$(VERSION)/ChirpLab$(VERSION).tar.gz

distZip :
	cd .. && \
	cat ChirpLab$(VERSION)/FORRELEASE.txt | $(ZIP) ChirpLab$(VERSION)/ChirpLab$(VERSION).zip -@



dist : distTar distZip

distMacOSX : distTarMacOSX distZip



clean :
	for d in $(SUBDIRS); do \
		(if [ -d $$d ]; then cd $$d && ${MAKE} clean; fi); \
	done; \
	rm -f $(TARGETS) ChirpLab$(VERSION).tar.gz ChirpLab$(VERSION).zip
