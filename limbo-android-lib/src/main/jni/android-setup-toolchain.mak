# DO NOT MODIFY THIS FILE
NDK_PLATFORM = platforms/$(APP_PLATFORM)

#PLATFORM CONFIG
# Ideally App platform used to compile should be equal or lower than the minSdkVersion in AndroidManifest.xml
# Note 1: Building for Android ARM host requires ndk17b and android-21
# Note 2: Building for Android x86 host requires ndk17b and android-21
# Note 3: Building for Android x86 host w/ KVM support requires ndk17b and android-21
# Note 4: Building for Android x86_64 host requires ndk17b and android-21
# Note 5: Building for Android ARM64 host requires ndk17b and android-21


ifeq ($(BUILD_HOST), arm64-v8a)
######### Armv8 64 bit (Newest ARM phones only, Supports VNC, Needs android-21)
include $(LIMBO_JNI_ROOT)/android-device-config/android-armv8.mak
else ifeq ($(BUILD_HOST), armeabi-v7a)
######### ARMv7 Soft Float  (Most ARM phones, Supports VNC and SDL, Needs android-21)
include $(LIMBO_JNI_ROOT)/android-device-config/android-armv7a-softfp.mak
else ifeq ($(BUILD_HOST), x86)
######### x86 (x86 Phones only, Supports VNC and SDL, Needs android-21)
include $(LIMBO_JNI_ROOT)/android-device-config/android-x86.mak
else ifeq ($(BUILD_HOST), x86_64)
######### x86_64 (x86 64bit Phones only, Supports VNC, Needs android-21)
include $(LIMBO_JNI_ROOT)/android-device-config/android-x86_64.mak
endif

TARGET_ARCH = 

ifeq ($(APP_ABI),armeabi-v7a)
    EABI = arm-linux-androideabi-$(GCC_TOOLCHAIN_VERSION)
    HOST_PREFIX = arm-linux-androideabi
    GNU_HOST = arm-unknown-linux-android
    TARGET_ARCH=arm
    APP_ABI_DIR=$(APP_ABI)
else ifeq ($(APP_ABI),arm64-v8a)
    EABI = aarch64-linux-android-$(GCC_TOOLCHAIN_VERSION)
    HOST_PREFIX = aarch64-linux-android
    GNU_HOST = aarch64-unknown-linux-android
    TARGET_ARCH=arm64
    APP_ABI_DIR=$(APP_ABI)
else ifeq ($(APP_ABI),x86)
    EABI = x86-$(GCC_TOOLCHAIN_VERSION)
    HOST_PREFIX = i686-linux-android
    GNU_HOST = i686-unknown-linux-android
    TARGET_ARCH=x86
    APP_ABI_DIR=$(APP_ABI)
else ifeq ($(APP_ABI),x86_64)
    EABI = x86_64-$(GCC_TOOLCHAIN_VERSION)
    HOST_PREFIX = x86_64-linux-android
    GNU_HOST = x86_64-unknown-linux-android
    TARGET_ARCH=x86_64
    APP_ABI_DIR=$(APP_ABI)
endif


# Since we need ndk 11 and above we need to fix some missing calls 
USE_NDK11 = -D__NDK11_FUNC_MISSING__

TOOLCHAIN_DIR = $(NDK_ROOT)/toolchains/$(EABI)/prebuilt/$(NDK_ENV)
TOOLCHAIN_CLANG_DIR = $(NDK_ROOT)/toolchains/llvm/prebuilt/$(NDK_ENV)

TOOLCHAIN_PREFIX := $(TOOLCHAIN_DIR)/bin/$(HOST_PREFIX)-
NDK_PROJECT_PATH := $(LIMBO_JNI_ROOT)/../
TOOLCHAIN_CLANG_PREFIX := $(TOOLCHAIN_CLANG_DIR)/bin

#$(warning NDK_TOOLCHAIN_VERSION = $(NDK_TOOLCHAIN_VERSION))

ifeq ($(NDK_TOOLCHAIN_VERSION),clang)
    $(warning clang)
    ##### CLANG binaries
    CC=$(TOOLCHAIN_CLANG_PREFIX)/clang
    #CXX=$(TOOLCHAIN_CLANG_PREFIX)/clang++
    AR=$(TOOLCHAIN_CLANG_PREFIX)/llvm-ar
    AS=$(TOOLCHAIN_CLANG_PREFIX)/llvm-as
    LNK=$(TOOLCHAIN_CLANG_PREFIX)/clang
    #LD=$(TOOLCHAIN_CLANG_PREFIX)/llvm-ld
    #NM=$(TOOLCHAIN_CLANG_PREFIX)/llvm-nm
    NDK_SYSROOT_ARCH_INC=-I$(NDK_ROOT)/sysroot/usr/include/$(HOST_PREFIX)
    NDK_SYSROOT_INC=-I$(NDK_ROOT)/sysroot/usr/include
else
    #NDK Toolchain
    CC=$(TOOLCHAIN_PREFIX)gcc
    #CXX=$(TOOLCHAIN_CLANG_PREFIX)/g++
    AR=$(TOOLCHAIN_PREFIX)ar
    AS=${TOOLCHAIN_PREFIX}as
    LNK = $(TOOLCHAIN_PREFIX)g++
    LD=${TOOLCHAIN_PREFIX}ld
    NM=${TOOLCHAIN_PREFIX}nm
endif

STRIP = $(TOOLCHAIN_PREFIX)strip
OBJ_COPY = $(TOOLCHAIN_PREFIX)objcopy


AR_FLAGS = crs
SYSROOT = $(NDK_ROOT)/$(NDK_PLATFORM)/arch-$(TARGET_ARCH)
SYS_ROOT = --sysroot=$(SYSROOT)
NDK_INCLUDE = $(NDK_ROOT)/$(NDK_PLATFORM)/arch-$(TARGET_ARCH)/usr/include


# INCLUDE_FIXED contains overrides for include files found under the toolchain's /usr/include.
# Hoping to get rid of those one day, when newer NDK versions are released.
INCLUDE_FIXED = $(LIMBO_JNI_ROOT)/include-fixed

# The logutils header is injected into all compiled files in order to redirect
# output to the Android console, and provide debugging macros.
LOGUTILS = $(LIMBO_JNI_ROOT)/compat/limbo_logutils.h

#Some fixes for Android compatibility
COMPATUTILS_FD = $(LIMBO_JNI_ROOT)/compat/limbo_compat_filesystem.h
COMPATUTILS_QEMU = $(LIMBO_JNI_ROOT)/compat/limbo_compat_qemu.h
COMPATMACROS = $(LIMBO_JNI_ROOT)/compat/limbo_compat_macros.h
COMPATANDROID = $(LIMBO_JNI_ROOT)/compat/limbo_compat.h

USR_LIB = \
-L$(TOOLCHAIN_DIR)/lib

ifeq ($(USE_NDK_PLATFORM21),true)
USE_PLATFORM21_FLAGS = -D__ANDROID_HAS_SIGNAL__ \
	-D__ANDROID_HAS_FS_IOC__ \
	-D__ANDROID_HAS_SYS_GETTID__ \
	-D__ANDROID_HAS_PARPORT__ \
	-D__ANDROID_HAS_IEEE__ \
	-D__ANDROID_HAS_STATVFS__ \
	-D__ANDROID__HAS_PTHREAD_ATFORK_
endif
	
ARCH_CFLAGS := $(ARCH_CFLAGS) -D__LIMBO__ -D__ANDROID__ -DANDROID -D__linux__ $(USE_NDK11) $(USE_PLATFORM21_FLAGS) 

# Needed for some c++ source code to compile some ARM 64 disas
# We don't need them right now
#STL_INCLUDE := -I$(NDK_ROOT)/sources/android/support/include
#STL_INCLUDE += -I$(NDK_ROOT)/sources/cxx-stl/stlport/stlport
#STL_INCLUDE += -I$(NDK_ROOT)/sources/cxx-stl/llvm-libc++/include
#STL_INCLUDE += -I$(NDK_ROOT)/sources/cxx-stl/llvm-libc++abi/include
#STL_INCLUDE += -D__STDC_CONSTANT_MACROS
#STL_LIB :=$(LIMBO_JNI_ROOT)/../obj/local/$(APP_ABI)/libstlport_shared.so
#STL_LIB :=$(LIMBO_JNI_ROOT)/../obj/local/$(APP_ABI)/libc++_shared.so
#CXX=$(TOOLCHAIN_PREFIX)g++

SYSTEM_INCLUDE = \
    -I$(INCLUDE_FIXED) \
    $(SYS_ROOT) \
    -I$(LIMBO_JNI_ROOT)/qemu/linux-headers \
    -I$(TOOLCHAIN_DIR_INC)/$(EABI)/include \
    -I$(NDK_INCLUDE) \
    $(NDK_SYSROOT_INC) \
    $(NDK_SYSROOT_ARCH_INC) \
    $(STL_INCLUDE) \
    -include $(LOGUTILS) \
    -include $(COMPATUTILS_FD) \
    -include $(COMPATUTILS_QEMU) \
    -include $(COMPATMACROS) \
    -include $(COMPATANDROID)
