#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/MapboxMobileEvents/MapboxMobileEvents/Resources/logger.html"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Navigation.storyboard"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/bg.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/en.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fa.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/it.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/lt.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/nl.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sl.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hant.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/carplay"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/close.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/exit-left.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/exit-right.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-closed-road.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-confusing-directions.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-gps.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-map-error.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-no-turn-allowed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-traffic.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-wrong-directions.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_car_crash.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_hazard.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_other.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_road_closed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_routing.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_turn_not_allowed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/location.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/minus.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/overview.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/pan-map.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/plus.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/recenter.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/report_checkmark.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/reroute-sound.dataset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/scroll.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/search-monocle.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/star.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/triangle.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/volume_off.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/volume_up.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/bg.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/en.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fa.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/it.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/lt.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/nl.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sl.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hant.lproj"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/MapboxMobileEvents/MapboxMobileEvents/Resources/logger.html"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Navigation.storyboard"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/bg.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/en.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fa.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/it.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/lt.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/nl.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sl.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Localizable.stringsdict"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj/Localizable.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hant.lproj/Navigation.strings"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/carplay"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/close.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/exit-left.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/exit-right.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-closed-road.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-confusing-directions.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-gps.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-map-error.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-no-turn-allowed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-traffic.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback-wrong-directions.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_car_crash.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_hazard.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_other.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_road_closed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_routing.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/feedback_turn_not_allowed.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/location.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/minus.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/overview.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/pan-map.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/plus.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/recenter.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/report_checkmark.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/reroute-sound.dataset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/scroll.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/search-monocle.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/star.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/triangle.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/volume_off.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets/volume_up.imageset"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ar.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/Base.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/bg.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ca.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/da.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/de.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/en.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/es.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fa.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/fr.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/he.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/hu.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/it.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ja.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ko.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/lt.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/nl.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-BR.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/pt-PT.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/ru.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sl.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/sv.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/uk.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/vi.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/yo.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hans.lproj"
  install_resource "${PODS_ROOT}/MapboxNavigation/MapboxNavigation/Resources/zh-Hant.lproj"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
