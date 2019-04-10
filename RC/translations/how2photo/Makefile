#
#
#

IMAGE_FILES = *.jpg *.gif
HTML_FILES = *.html
REMOTE = akyykKuz@www.askyyk.com
DST_DIR	= www/RC/translations/how2photo
CP	= scp
SSH	= ssh

all:
	@echo What?
	@echo make install-images
	@echo "         " or
	@echo make make-dir install-html

make-dir:
	$(SSH) $(REMOTE) mkdir -p $(DST_DIR)
install-images:
	$(CP) $(IMAGE_FILES) $(REMOTE):$(DST_DIR)
install-html:
	$(CP) $(HTML_FILES) $(REMOTE):$(DST_DIR)
