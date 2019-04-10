#
#
#

IMAGE_FILES = *.jpg *.gif
HTML_FILES = Valve_1.ru.html Valve_2.ru.html
REMOTE = akyykKuz@www.askyyk.com
DST_DIR	= www/RC/translations/4-stroke-valves
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
