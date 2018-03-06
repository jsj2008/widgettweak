#!/bin/bash
rm -r /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app
cp -r /Users/mengqingru/Library/Developer/Xcode/DerivedData/Build/Products/Debug-iphoneos/BlockTest.app /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app
mv /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app/BlockTest /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app/BlockTest_
cp /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app/BlockTest
/opt/theos/bin/ldid -S/Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/Entitlements.plist /Users/mengqingru/Desktop/ios8widgettweak/layout/Applications/BlockTest.app/BlockTest_
