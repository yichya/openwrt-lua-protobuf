# SPDX-License-Identifier: MIT

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-protobuf
PKG_VERSION:=0.3.3
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://github.com/starwing/lua-protobuf.git
PKG_MIRROR_HASH:=3468678cd6709166295d9ae6c4eb870defda88c763f1e4a95193bea54f6a5257
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0.3.3

include $(INCLUDE_DIR)/package.mk

define Package/lua-protobuf
    SUBMENU:=Lua
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=Lua-Protobuf
    DEPENDS:=+lua
    MAINTAINER:=yichya <mail@yichya.dev>
endef

define Package/lua-protobuf/description
	Lua bindings to protobuf
endef

define Build/Compile
	cd $(PKG_BUILD_DIR); $(TARGET_CC) $(TARGET_CFLAGS) $(EXTRA_CFLAGS) -fPIC -flto -shared -I$(STAGING_DIR)/usr/include pb.c -o pb.so
endef

define Package/lua-protobuf/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pb.so $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/protoc.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-protobuf))

