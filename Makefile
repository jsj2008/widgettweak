export ARCHS = armv7 armv7s arm64
<<<<<<< HEAD
export TARGET = iphone:9.2:9.0
export THEOS = /opt/theos
export THEOS_MAKE_PATH = /opt/theos/makefiles 
=======
export TARGET = iphone:8.4:8.0

>>>>>>> bcfcf0a6df91bf3ea6a7991492c044dcbf6fb557

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
