#!/usr/bin/env bash
set -e

NAME="redborder-sensors"
SPEC_FILE="packaging/rpm/redborder-sensors.spec"
if [ -f "VERSION" ]; then
    VERSION=$(tr -d '[:space:]' < VERSION)
else
    VERSION=$(rpmspec -P "$SPEC_FILE" 2>/dev/null | grep "^Version:" | awk '{print $2}')
fi
BUILD_DIR="/tmp/rpmbuild-sensors"

if [ -z "$VERSION" ]; then
    echo "[-] Error: Could not determine version"
    exit 1
fi

echo "[+] Preparing build directory: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{SOURCES,SPECS,RPMS,SRPMS,BUILD,BUILDROOT}

echo "[+] Creating source tarball..."
STAGING_DIR="$BUILD_DIR/SOURCES/$NAME-$VERSION"
mkdir -p "$STAGING_DIR"
cp -r . "$STAGING_DIR"
# Clean up build artifacts before tarring
(cd "$STAGING_DIR" && make clean)
tar -czf "$BUILD_DIR/SOURCES/$NAME-$VERSION.tar.gz" -C "$BUILD_DIR/SOURCES" "$NAME-$VERSION"

echo "[+] Running rpmbuild..."
rpmbuild -ba --define "_topdir $BUILD_DIR" --define "__version $VERSION" --define "__release 1" "$SPEC_FILE"

echo ""
echo "[+] RPM build complete!"
echo "[+] Packages available in: $BUILD_DIR/RPMS/x86_64/"
ls -l "$BUILD_DIR/RPMS/x86_64/"
