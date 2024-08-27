ARCHS := arm64 arm64e
TARGET := iphone:clang:latest:15.0
DEBUG := 0
include $(THEOS)/makefiles/common.mk
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = Velvet2

$(TWEAK_NAME)_FILES = src/Tweak.xm src/UIColor+Velvet.m src/Velvet2PrefsManager.m src/ColorDetection.m src/Velvet2Colorizer.m
$(TWEAK_NAME)_CFLAGS := -fobjc-arc -Os

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
