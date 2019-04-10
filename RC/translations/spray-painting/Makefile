#
#
#

IMAGE_FILES = *.jpg no01s000.gif no02s000.gif no03s000.gif no04s000.gif \
	no05s000.gif no06s000.gif no07s000.gif no08s000.gif no10s000.gif \
	no11s000.gif no12s000.gif no13s000.gif no14s000.gif \
	arrow_l0.gif \
	arrow_l1.gif \
	arrow_l_.gif \
	arrow_r0.gif \
	arrow_r1.gif \
	arrow_r_.gif \
	redsquare.gif
HTML_FILES = *.ru.html
REMOTE = akyykKuz@www.askyyk.com
DST_DIR	= www/RC/translations/spray-painting
CP	= scp
SSH	= ssh

all:
	@echo What?
	@echo make install-images
	@echo "         " or
	@echo make install-html

install-images:
	$(SSH) $(REMOTE) mkdir -p $(DST_DIR)
	$(CP) $(IMAGE_FILES) $(REMOTE):$(DST_DIR)
install-html:
	$(SSH) $(REMOTE) mkdir -p $(DST_DIR)
	$(CP) $(HTML_FILES) $(REMOTE):$(DST_DIR)
