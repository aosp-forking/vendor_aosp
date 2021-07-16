# Kraken version
PRODUCT_BRAND ?= Kraken
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

CUSTOM_BUILD_TYPE ?= UNOFFICIAL
VANILLA_BUILD ?= false
CUSTOM_VERSION_PROP := eleven
CUSTOM_PLATFORM_VERSION := 11
CUSTOM_BUILD_DATE=$(shell date +"%Y%m%d-%H%M")
CUSTOM_DEVICE := $(CUSTOM_BUILD)

# GMS
ifeq ($(VANILLA_BUILD), true)
    CUSTOM_APPS_VERSION := Vanilla
else
    $(call inherit-product, vendor/gapps/config.mk)
    CUSTOM_APPS_VERSION := GApps
    PRODUCT_PACKAGES += KrakenGAppsOverlay
endif

ifeq ($(CUSTOM_BUILD_TYPE), OFFICIAL)
    CUSTOM_VERSION := Kraken-$(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_APPS_VERSION)-$(CUSTOM_BUILD_DATE)-$(CUSTOM_DEVICE)
    PRODUCT_PACKAGES += Updater
else
    CUSTOM_VERSION := Kraken-$(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_APPS_VERSION)-$(CUSTOM_BUILD_DATE)-$(CUSTOM_DEVICE)-$(CUSTOM_BUILD_TYPE)
endif

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/aosp/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/aosp/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/aosp/prebuilt/common/bin/50-custom.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-custom.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/aosp/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/aosp/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/aosp/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/aosp/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

# Custom-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/aosp/config/permissions/custom-sysconfig.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/custom-sysconfig.xml

PRODUCT_COPY_FILES += \
    vendor/aosp/config/permissions/allowlist_com.android.omadm.service.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/allowlist_com.android.omadm.service.xml \
    vendor/aosp/config/permissions/com.android.omadm.service.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.android.omadm.service.xml \
    vendor/aosp/config/permissions/com.verizon.apn.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.verizon.apn.xml \
    vendor/aosp/config/permissions/com.verizon.services.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.verizon.services.xml \
    vendor/aosp/config/permissions/features-verizon.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/features-verizon.xml \
    vendor/aosp/config/permissions/obdm_permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/obdm_permissions.xml \
    vendor/aosp/config/permissions/vzw_mvs_permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/vzw_mvs_permissions.xml

# Copy all Custom-specific init rc files
$(foreach f,$(wildcard vendor/aosp/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/aosp/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0719.kl

# Permissions
PRODUCT_COPY_FILES += \
    vendor/aosp/config/permissions/org.lineageos.android.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/org.lineageos.android.xml \
    vendor/aosp/config/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Include AOSP audio files
include vendor/aosp/config/aosp_audio.mk

ifneq ($(TARGET_DISABLE_CUSTOM_SDK), true)
# SDK
include vendor/aosp/config/custom_sdk_common.mk
endif

# TWRP
ifeq ($(WITH_TWRP),true)
RECOVERY_VARIANT := twrp
endif

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# AOSP packages
PRODUCT_PACKAGES += \
    Terminal

# Custom packages
PRODUCT_PACKAGES += \
    CustomParts \
    CustomSettingsProvider

# Themes
PRODUCT_PACKAGES += \
    CustomThemesStub \
    ThemePicker

# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig

# Extra tools
PRODUCT_PACKAGES += \
    7z \
    bash \
    curl \
    getcap \
    htop \
    lib7z \
    libsepol \
    nano \
    pigz \
    setcap \
    unrar \
    vim \
    wget \
    zip

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mke2fs \
    mkfs.ntfs \
    mount.ntfs

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

# Dex preopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    FaceUnlockService
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face_unlock_service.enabled=$(TARGET_FACE_UNLOCK_SUPPORTED)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/aosp/build/target/product/security/custom

-include vendor/custom-priv/keys/keys.mk

-include $(WORKSPACE)/build_env/image-auto-bits.mk

# Blurs
ifneq ($(filter msm8226 msm8610 msm8974 msm8992 msm8994 msm8909 msm8916 msm8937 msm8953 msm8996 msm8998 sdm660,$(TARGET_BOARD_PLATFORM)),)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.sf.blurs_are_expensive=0 \
    ro.surface_flinger.supports_background_blur=0
else
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1
endif

# hasNotch
ifneq ($(filter begonia beryllium ginkgo joyeuse lavender curtana excalibur gram mojito sweet vayu,$(CUSTOM_DEVICE)),)
PRODUCT_PACKAGES += \
    KrakenHasNotchOverlay
endif

# Camera
PRODUCT_PACKAGES += \
    GoogleCameraGo

# Custom Fonts
TARGET_INCLUDE_CUSTOM_FONTS ?= true
ifeq ($(TARGET_INCLUDE_CUSTOM_FONTS),true)
include vendor/aosp/fonts/fonts.mk
endif

# Bootanimation
include vendor/aosp/prebuilt/common/bootanimation/bootanimation.mk

# Overlays
include vendor/aosp/overlay/overlays.mk

# Accents
include vendor/aosp/overlay/Accents/accents.mk

# Pixel Style
include vendor/aosp/pixelstyle/styles.mk
