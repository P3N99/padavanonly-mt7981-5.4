#!/bin/bash
svn_export() {
	# 参数1是分支名, 参数2是子目录, 参数3是目标目录, 参数4仓库地址
 	echo -e "clone $4/$2 to $3"
	TMP_DIR="$(mktemp -d)" || exit 1
 	ORI_DIR="$PWD"
	[ -d "$3" ] || mkdir -p "$3"
	TGT_DIR="$(cd "$3"; pwd)"
	git clone --depth 1 -b "$1" "$4" "$TMP_DIR" >/dev/null 2>&1 && \
	cd "$TMP_DIR/$2" && rm -rf .git >/dev/null 2>&1 && \
	cp -af . "$TGT_DIR/" && cd "$ORI_DIR"
	rm -rf "$TMP_DIR"
}

find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

rm -rf ./feeds/packages/lang/golang 
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
rm -rf ./feeds/luci/applications/luci-app-argon-config
rm -rf ./feeds/luci/themes/luci-theme-argon


git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# turboacc 补丁
# curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a

# 个性化设置
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ P3NGG build $(TZ=UTC-8 date "+%Y.%m.%d")')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
sed -i 's/ImmortalWrt/MT7981/' package/base-files/files/bin/config_generate
sed -i "s/key='.*'/key=123456789/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/country='.*'/country='CN'/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# sed -i "s/encryption='.*'/encryption='sae-mixed'/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

# DNS劫持
# sed -i '/dns_redirect/d' package/network/services/dnsmasq/files/dhcp.conf
# adguardhome
VER=$(grep PKG_VERSION package/luci-app-adguardhome/Makefile | sed 's/-/\./g')
sed -i "s/PKG_VERSION:=.*/$VER/g" package/luci-app-adguardhome/Makefile
cd package
# 汉化
curl -sfL -o ./convert_translation.sh https://github.com/kenzok8/small-package/raw/main/.github/diy/convert_translation.sh
chmod +x ./convert_translation.sh && bash -v ./convert_translation.sh
