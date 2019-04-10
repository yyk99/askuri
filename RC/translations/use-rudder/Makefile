#
#
#

#IMAGE_FILES = *.jpg *.gif
IMAGE_FILES = *.jpg
HTML_FILES = index.ru.html
REMOTE = akyykKuz@www.askyyk.com
DST_DIR	= www/RC/translations/use-rudder
CP	= scp
SSH	= ssh

all:
	@echo What?
	@echo make install-images
	@echo "         " or
	@echo make mkdir install-html
mkdir:
	$(SSH) $(REMOTE) mkdir -p $(DST_DIR)
install-images:
	$(CP) $(IMAGE_FILES) $(REMOTE):$(DST_DIR)
install-html:
	$(CP) $(HTML_FILES) $(REMOTE):$(DST_DIR)
