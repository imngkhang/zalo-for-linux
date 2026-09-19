#!/usr/bin/env bash

set -euo pipefail

# 1. Khai báo tham số và biến môi trường
VER="${1:-unknown}"
OUTNAME="${2:?Error: No OUTNAME given}"
DIST_DIR="${3:?Error: No DIST_DIR given}"

export ARCH="x86_64"
export APP_NAME="Zalo"
export DESKTOP="zalo.desktop"
export ICON="zalo.png"
export STARTUPWMCLASS="zalo"
export OUTPATH="${DIST_DIR}"
export UPINFO="gh-releases-zsync|doandat943|zalo-for-linux|latest|${OUTNAME}.zsync"
export VERSION="$VER"

APPDIR="${DIST_DIR}/squashfs-root"
APPIMAGETOOL="${DIST_DIR}/appimagetool"

export APPDIR OUTNAME 

echo "=== Building Zalo AppImage for ${ARCH} ==="

# 2. Kiểm tra điều kiện đầu vào
if [[ ! -f "${DIST_DIR}/${OUTNAME}" ]]; then
  echo "Error: Cannot find ${OUTNAME}, please run the builder first." >&2
  exit 1
fi

# 3. Chuẩn bị công cụ appimagetool (Quick-Sharun)
if [[ ! -f "$APPIMAGETOOL" ]]; then
  echo "Downloading appimagetool..."
  wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O "$APPIMAGETOOL"
  chmod +x "$APPIMAGETOOL"
fi

# 4. Giải nén AppImage gốc
echo "Extracting AppImage..."
chmod +x "${DIST_DIR}/${OUTNAME}"
cd "$DIST_DIR"
./"$OUTNAME" --appimage-extract >/dev/null 2>&1

if [[ ! -d "$APPDIR" ]]; then
  echo "Error: Cannot find ${APPDIR}, extraction failed." >&2
  exit 1
fi

# 5. Dọn dẹp file cũ trước khi đóng gói lại
rm -f "$OUTNAME"

# 6. Đóng gói AppImage mới
echo "Packaging $OUTNAME..."
"$APPIMAGETOOL" --make-appimage

# 7. Dọn dẹp thư mục tạm và phân quyền
rm -rf "$APPDIR" "${DIST_DIR}/appinfo"
chmod +x "$OUTNAME" || true

echo "=== Build completed: ${DIST_DIR}/${OUTNAME} ==="
exit 