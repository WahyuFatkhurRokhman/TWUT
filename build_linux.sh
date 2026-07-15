#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# KONFIGURASI - SESUAIKAN DENGAN PROJECT KAMU
# ============================================================
APP_NAME="Twut"                   # nama executable hasil `flutter build linux`
                                    # (cek di build/linux/x64/release/bundle/, nama file binary-nya —
                                    # ini diambil dari BINARY_NAME di linux/CMakeLists.txt, BUKAN dari pubspec.yaml)
APP_DISPLAY_NAME="TWUT"           # nama yang tampil ke user / di judul jendela
APP_VERSION="1.1.0"               # versi rilis
ARCH="x86_64"
ICON_PATH="assets/images/app_icon.png" # icon untuk AppImage (WAJIB .png, disarankan 256x256)
TAR_ICON_PATH="assets/app_icon.ico"    # icon opsional yang ikut disalin ke dalam tar.gz (kosongkan "" kalau tidak perlu)
CATEGORY="AudioVideo;"            # HANYA satu kategori utama (appimagetool warning kalau lebih dari 1)
OUTPUT_DIR="releases"
# ============================================================

BUNDLE_DIR="build/linux/x64/release/bundle"
APPDIR="${OUTPUT_DIR}/${APP_NAME}.AppDir"

echo "==> 1. Build Flutter (release)"
flutter build linux --release

if [ ! -f "${BUNDLE_DIR}/${APP_NAME}" ]; then
  echo "!! Executable '${APP_NAME}' tidak ditemukan di ${BUNDLE_DIR}"
  echo "   Isi folder itu:"
  ls -la "${BUNDLE_DIR}"
  echo "   -> Update variabel APP_NAME di atas sesuai nama file yang benar, lalu jalankan ulang."
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

# ------------------------------------------------------------
echo "==> 2. Bikin .tar.gz"
# ------------------------------------------------------------
TAR_NAME="${APP_DISPLAY_NAME}-v${APP_VERSION}-linux-${ARCH}.tar.gz"
TMP_TAR_ROOT=$(mktemp -d)
cp -r "${BUNDLE_DIR}" "${TMP_TAR_ROOT}/${APP_NAME}"
if [ -n "${TAR_ICON_PATH}" ] && [ -f "${TAR_ICON_PATH}" ]; then
  cp "${TAR_ICON_PATH}" "${TMP_TAR_ROOT}/${APP_NAME}/"
elif [ -n "${TAR_ICON_PATH}" ]; then
  echo "    !! TAR_ICON_PATH (${TAR_ICON_PATH}) tidak ditemukan, lewati."
fi
tar -czf "${OUTPUT_DIR}/${TAR_NAME}" -C "${TMP_TAR_ROOT}" "${APP_NAME}"
rm -rf "${TMP_TAR_ROOT}"
echo "    -> ${OUTPUT_DIR}/${TAR_NAME}"

# ------------------------------------------------------------
echo "==> 3. Susun AppDir untuk AppImage"
# ------------------------------------------------------------
rm -rf "${APPDIR}"
mkdir -p "${APPDIR}/usr/bin" "${APPDIR}/usr/share/icons/hicolor/256x256/apps" "${APPDIR}/usr/share/applications"

# Seluruh isi bundle (executable + lib/ + data/) ditaruh di usr/bin
# supaya path-nya predictable dan AppRun tidak salah tebak lokasi.
cp -r "${BUNDLE_DIR}/." "${APPDIR}/usr/bin/"
chmod +x "${APPDIR}/usr/bin/${APP_NAME}"

if [ -f "${ICON_PATH}" ]; then
  cp "${ICON_PATH}" "${APPDIR}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
  cp "${ICON_PATH}" "${APPDIR}/${APP_NAME}.png"
else
  echo "    !! ICON_PATH (${ICON_PATH}) tidak ditemukan — AppImage tetap jalan tapi tanpa ikon."
fi

cat > "${APPDIR}/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${APP_DISPLAY_NAME}
Exec=${APP_NAME}
Icon=${APP_NAME}
Categories=${CATEGORY}
Terminal=false
EOF
cp "${APPDIR}/${APP_NAME}.desktop" "${APPDIR}/usr/share/applications/"

# AppRun dengan path eksplisit ke usr/bin/<executable> — ini yang mencegah
# error "No such file or directory" yang kemarin muncul (AppRun salah nebak lokasi binary)
cat > "${APPDIR}/AppRun" <<EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\${HERE}/usr/bin/lib:\${LD_LIBRARY_PATH:-}"
exec "\${HERE}/usr/bin/${APP_NAME}" "\$@"
EOF
chmod +x "${APPDIR}/AppRun"

# ------------------------------------------------------------
echo "==> 4. Siapkan appimagetool"
# ------------------------------------------------------------
if command -v appimagetool >/dev/null 2>&1; then
  APPIMAGETOOL="appimagetool"
else
  if [ ! -f "./appimagetool.AppImage" ]; then
    wget -O appimagetool.AppImage \
      "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool.AppImage
  fi
  APPIMAGETOOL="./appimagetool.AppImage"
fi

# ------------------------------------------------------------
echo "==> 5. Bungkus jadi AppImage"
# ------------------------------------------------------------
APPIMAGE_NAME="${APP_DISPLAY_NAME}-v${APP_VERSION}-linux-${ARCH}.AppImage"
ARCH="${ARCH}" "${APPIMAGETOOL}" --no-appstream "${APPDIR}" "${OUTPUT_DIR}/${APPIMAGE_NAME}"
rm -rf "${APPDIR}"

echo ""
echo "SELESAI!"
echo "  tar.gz   : ${OUTPUT_DIR}/${TAR_NAME}"
echo "  AppImage : ${OUTPUT_DIR}/${APPIMAGE_NAME}"
echo ""
echo "Tes AppImage-nya:"
echo "  chmod +x ${OUTPUT_DIR}/${APPIMAGE_NAME}"
echo "  ./${OUTPUT_DIR}/${APPIMAGE_NAME}"