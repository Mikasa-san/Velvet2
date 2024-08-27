TARGET := iphone:clang:14.5:15.0
INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Velvet2

$(BUNDLE_NAME)_FILES = $(wildcard *.m CustomCells/*.m ../src/Velvet2PrefsManager.m ../src/UIColor+Velvet.m ../src/ColorDetection.m ../src/Velvet2Colorizer.m)
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
Velvet2_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"'

include $(THEOS_MAKE_PATH)/bundle.mk
