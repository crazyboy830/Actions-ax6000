#!/bin/bash
#
# Merged DIY script for OpenWrt build pipeline.
# Usage:
#   ./diy.sh pre   # before feeds update/install
#   ./diy.sh feeds # after feeds update, before feeds install
#   ./diy.sh post  # after feeds install, before build
#

set -euo pipefail

STAGE="${1:-pre}"

case "$STAGE" in
  pre)
    # Keep stage for compatibility.
    ;;

  feeds)
    # Pin external sources for reproducible builds. You may override these via env.
    PASSWALL2_LUCI_REF="${PASSWALL2_LUCI_REF:-9f080c65786f3838c19e21186fdc3a5f408e38ce}"
    PASSWALL_PACKAGES_REF="${PASSWALL_PACKAGES_REF:-291522a4918deb65c464584cfd912c62ac874085}"
    GOLANG_FEED_REF="${GOLANG_FEED_REF:-9384daa461a616183457be2baf8eebcf914044fb}"
    V2RAY_GEODATA_REF="${V2RAY_GEODATA_REF:-2e3845caae172326f02b3406048c7a3613f3dee5}"

    # Pin PassWall feed repos declared in feeds.conf.default.
    if [ -d feeds/passwall2/.git ]; then
      git -C feeds/passwall2 fetch --depth=1 origin "$PASSWALL2_LUCI_REF"
      git -C feeds/passwall2 checkout --detach "$PASSWALL2_LUCI_REF"
    fi
    if [ -d feeds/passwall_packages/.git ]; then
      git -C feeds/passwall_packages fetch --depth=1 origin "$PASSWALL_PACKAGES_REF"
      git -C feeds/passwall_packages checkout --detach "$PASSWALL_PACKAGES_REF"
    fi

    # Keep v2ray-geodata source aligned with the referenced profile.
    rm -rf feeds/packages/net/v2ray-geodata package/v2ray-geodata
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
    git -C package/v2ray-geodata fetch --depth=1 origin "$V2RAY_GEODATA_REF"
    git -C package/v2ray-geodata checkout --detach "$V2RAY_GEODATA_REF"

    # Align golang toolchain for PassWall/Xray packages.
    rm -rf feeds/packages/lang/golang
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
    git -C feeds/packages/lang/golang fetch --depth=1 origin "$GOLANG_FEED_REF"
    git -C feeds/packages/lang/golang checkout --detach "$GOLANG_FEED_REF"
    ;;

  post)
    # Keep existing default LAN IP behavior from current repository.
    cfg_file="package/base-files/files/bin/config_generate"
    if [ -f "$cfg_file" ]; then
      sed -i 's/192\.168\.1\.1/192.168.31.1/g' "$cfg_file"
    else
      echo "Missing file: $cfg_file" >&2
      exit 1
    fi
    ;;

  *)
    echo "Unknown stage: $STAGE (expected: pre|feeds|post)" >&2
    exit 1
    ;;
esac
