include $(TOPDIR)/rules.mk

PKG_NAME:=wifi_schedule
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/wifi_schedule
  SECTION:=LuCI
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=wifi_schedule
  DEPENDS:=
  PKGARCH:=all
  MAINTAINER:=Ameng
endef

define Package/wifi_schedule/description
wifi_schedule
endef

define Build/Compile
endef

define Package/wifi_schedule/preinst
endef

define Package/wifi_schedule/postinst
endef

define Package/wifi_schedule/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,wifi_schedule))
