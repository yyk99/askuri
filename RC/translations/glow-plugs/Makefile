#
#
#

IMAGE_FILES = *.jpg *.gif
HTML_FILES = *.ru.html site_sty.css
REMOTE = akyykKuz@www.askyyk.com
DST_DIR	= www/RC/translations/glow-plugs
CP	= scp
SSH	= ssh

all:
	@echo What?
	@echo make install-images
	@echo "         " or
	@echo make dirs install-html

dirs:
	$(SSH) $(REMOTE) mkdir -p $(DST_DIR)
install-images:
	$(CP) $(IMAGE_FILES) $(REMOTE):$(DST_DIR)
install-html:
	$(CP) $(HTML_FILES) $(REMOTE):$(DST_DIR)
