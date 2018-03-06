export ARCHS = armv7 armv7s arm64
export THEOS = /opt/theos
export THEOS_MAKE_PATH = /opt/theos/makefiles 


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = blocktest_ios8_tweak
blocktest_ios8_tweak_FILES = Tweak.xm SMSTweak.xm
blocktest_ios8_tweak_LDFLAGS = -lsimulatetouch
blocktest_ios8_tweak_FRAMEWORKS = CoreGraphics UIKit Foundation 
blocktest_ios8_tweak_PRIVATE_FRAMEWORKS = AppSupport ChatKit IMFoundation IDS IMCore IOSurface IOKit IOMobileFramebuffer 
blocktest_ios8_tweak_LIBRARIES = rocketbootstrap
blocktest_ios8_tweak_CFLAGS = -I./headers/ -I./headers/IOSurface

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
