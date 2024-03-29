#!/bin/bash
set -e

echo
echo '#'
echo '# System Report'
echo '#  Pull Requests are welcome!'
echo '#'
echo

# Make sure that the reported version is only
#  a single line!
echo
echo "=== Pre-installed tool versions ========"

ver_line="$(gradle --version | grep 'Gradle ')" ;     echo "* Gradle: $ver_line"
ver_line="$(mvn --version | grep 'Apache Maven')" ;   echo "* Maven: $ver_line"
ver_line="$(fastlane --version | grep 'fastlane ')" ;   echo "* Fastlane: $ver_line"
ver_line="$( javac -version 2>&1 )" ;                 echo "* Java: $ver_line"

echo "========================================"
echo

echo
echo "=== Testing Android tools =============="
echo " * adb path:"
which adb
echo
echo " * adb version:"
adb version
echo "========================================"
echo

echo
echo "=== Android tools/dirs ================="
echo
echo "* ANDROID_HOME:"
ls -a1 ${ANDROID_HOME}
echo
echo "* platform-tools:"
ls -1 ${ANDROID_HOME}/platform-tools
echo
echo "* build-tools:"
ls -1 ${ANDROID_HOME}/build-tools
echo
echo "* extras:"
tree -L 2 ${ANDROID_HOME}/extras
echo
echo "* platforms:"
ls -1 ${ANDROID_HOME}/platforms
echo
echo "* system-images:"
tree -L 3 ${ANDROID_HOME}/system-images
echo "========================================"
echo
