THEOS_DEVICE_IP = 192.168.1.249
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifyFullScreenArtworkUI
SpotifyFullScreenArtworkUI_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotify"
