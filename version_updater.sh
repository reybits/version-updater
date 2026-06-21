#!/bin/bash
################################################
#
#  Andrey A. Ugolnik
#  https://github.com/reybits
#  and@reybits.dev
#
#  Version updater script.
#  v0.5.3, 2026.06.21
#
#  Usage:
#    ./version_updater.sh <TYPE> <VERSION> <PATH/TO/FILE> [BUNDLE_NAME]
#
#  Version format:
#    X.Y.Z
#  Where:
#    X - major version
#    Y - minor version
#    Z - patch version
#    X, Y, Z - integers, no leading zeros allowed,
#              not more than 2 digits each.
#
################################################

if [ "$#" -lt 3 ]; then
    echo "Usage $0 <TYPE> <VERSION> <PATH/TO/FILE> [BUNDLE_NAME]"
    echo "Where TYPE is one of: xcode, json, cpp, gradle, html, yand, windows"
    exit 1
fi

# ------------------------------------------------------------------------------

type="$1"
version="$2"
file_path="$3"

# ------------------------------------------------------------------------------

remove_bak() {
    # cat "$1"
    # mv -f "$1.bak" "$1"
    rm -f "$1.bak"
}

# ------------------------------------------------------------------------------
# Convert a marketing version "X.Y.Z" into a numeric build code.
# Each component is zero-padded to two digits and concatenated (6.24.3 -> 62403).
# ------------------------------------------------------------------------------

version_to_code() {
    local version_parts=(${1//\./ })

    local code=""
    for part in "${version_parts[@]}"; do
        code+=$(printf "%02d" "$part")
    done

    echo $((10#$code))
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# build="N" (numeric build code, like the gradle versionCode)
# version="X.Y.Z"
# ------------------------------------------------------------------------------

update_html() {
    local code=$(version_to_code "${version}")

    local regex_build="s/build=\"[0-9.]+\"/build=\"${code}\"/g"
    local regex_version="s/version=\"([0-9]+\.[0-9]+\.[0-9]+)\"/version=\"${version}\"/g"
    local regex_js_versioning="s#js/main.js\?ver=[0-9]+\.[0-9]+\.[0-9]+#js/main.js?ver=${version}#"

    sed -E -i .bak -e "${regex_build}" -e "${regex_version}" -e "${regex_js_versioning}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# const CACHE_NAME = "BUNDLE_NAME-vX.Y.Z"
# ------------------------------------------------------------------------------

update_yand() {
    local bundle="$2"
    local regex="s/const[[:space:]]*CACHE_NAME[[:space:]]*=[[:space:]]*\"${bundle}-v([0-9]+\.[0-9]+\.[0-9]+)\"/const CACHE_NAME = \"${bundle}-v${version}\"/g"

    sed -E -i .bak "${regex}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# char* Version = "X.Y.Z"
# ------------------------------------------------------------------------------

update_cpp() {
    local regex="s/char[[:space:]]*\*[[:space:]]*Version[[:space:]]*=[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+)\"/char* Version = \"${version}\"/g"

    sed -E -i .bak "${regex}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# versionCode = N
# versionName = "X.Y.Z"
# ------------------------------------------------------------------------------

update_gradle() {
    local code=$(version_to_code "${version}")

    local version_code="s/versionCode[[:space:]]*=[[:space:]]*([0-9]+)/versionCode = ${code}/g"
    local version_name="s/versionName[[:space:]]*=[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+)\"/versionName = \"${version}\"/g"

    sed -E -i .bak -e "${version_code}" -e "${version_name}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# CURRENT_PROJECT_VERSION = N (numeric build, derived like the gradle versionCode)
# MARKETING_VERSION = X.Y.Z
# ------------------------------------------------------------------------------

update_xcode() {
    local code=$(version_to_code "${version}")

    local p_version="s/CURRENT_PROJECT_VERSION[[:space:]]*=[[:space:]]*[0-9.]+/CURRENT_PROJECT_VERSION = ${code}/g"
    local m_version="s/MARKETING_VERSION[[:space:]]*=[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)/MARKETING_VERSION = ${version}/g"

    sed -E -i .bak -e "${p_version}" -e "${m_version}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# "androidVersion": "X.Y.Z"
# "iosVersion": "X.Y.Z"
# "otherVersion": "X.Y.Z"
# ------------------------------------------------------------------------------

update_json() {
    local androidVersion="s/\"androidVersion\":[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+)\"/\"androidVersion\": \"${version}\"/g"
    local iosVersion="s/\"iosVersion\":[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+)\"/\"iosVersion\": \"${version}\"/g"
    local otherVersion="s/\"otherVersion\":[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+)\"/\"otherVersion\": \"${version}\"/g"

    sed -E -i .bak -e "${androidVersion}" -e "${iosVersion}" -e "${otherVersion}" "$1"
    remove_bak "$1"
}

# ------------------------------------------------------------------------------
# Looking for version patterns:
# VALUE "FileVersion", "X.Y.Z.0"
# VALUE "ProductVersion", "X.Y.Z.0"
# FILEVERSION X,Y,Z,0
# PRODUCTVERSION X,Y,Z,0
# ------------------------------------------------------------------------------

update_windows() {
    local comma_version="${version//\./,}"

    # VALUE "FileVersion", "0.2.1.0"
    local fileVersion="s/\"FileVersion\",[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\"/\"FileVersion\", \"${version}.0\"/g"
    # VALUE "ProductVersion", "0.2.1.0"
    local productVersion="s/\"ProductVersion\",[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\"/\"ProductVersion\", \"${version}.0\"/g"
    # FILEVERSION 1,0,3,0
    local fileVersionNum="s/FILEVERSION[[:space:]]+([0-9]+,[0-9]+,[0-9]+,[0-9]+)/FILEVERSION ${comma_version},0/g"
    # PRODUCTVERSION 1,0,3,0
    local productVersionNum="s/PRODUCTVERSION[[:space:]]+([0-9]+,[0-9]+,[0-9]+,[0-9]+)/PRODUCTVERSION ${comma_version},0/g"

    cat "$1" | iconv -f utf-16 -t utf-8 | sed -E -e "${fileVersion}" -e "${productVersion}" -e "${fileVersionNum}" -e "${productVersionNum}" | iconv -f utf-8 -t utf-16 >"$1.bak"
    mv "$1.bak" "$1"
}

# ------------------------------------------------------------------------------

if [ ! -f "${file_path}" ]; then
    # Silently exit if file not found
    # echo "File '${file_path}' not found!"
    exit 1
fi

header() {
    echo "Updating version to '${version}' of type '${type}' in file '${file_path}'"
}

case ${type} in
xcode)
    header
    update_xcode "${file_path}"
    ;;

json)
    header
    update_json "${file_path}"
    ;;

cpp)
    header
    update_cpp "${file_path}"
    ;;

gradle)
    header
    update_gradle "${file_path}"
    ;;

html)
    header
    update_html "${file_path}"
    ;;

yand)
    header
    if [ "$#" -lt 4 ]; then
        echo "Usage $0 <TYPE> <VERSION> <PATH/TO/FILE> <BUNDLE_NAME>"
        exit 1
    fi
    update_yand "${file_path}" "${4}"
    ;;

windows)
    header
    update_windows "${file_path}"
    ;;

*)
    echo "'${type}' Unknown type!"
    ;;
esac
