#
# Copyright (C) 2006 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Configuration for builds hosted on linux-x86.
# Included by combo/select.mk

# $(1): The file to check
define get-file-size
stat --format "%s" "$(1)" | tr -d '\n'
endef

# Special case for the Linux SDK: We need to use a special cross-toolchain
# that generates machine code that will run properly on Ubuntu 8.04 (Hardy)
# By default, the code generated by the Lucid host toolchain will not run
# on previous versions of the platform, due to GLibc ABI mistmatches
# (Lucid is 2.11, Hardy is 2.7)
#
# Note that components that need to be built as 64-bit (e.g. clearsilver
# which is loaded by the 64-bit JVM through JNI), will have to use
# LOCAL_CC and LOCAL_CXX to override this.
#
ifeq ($(TARGET_PRODUCT),sdk)
HOST_SDK_TOOLCHAIN_PREFIX := prebuilt/linux-x86/toolchain/i686-linux-glibc2.7-4.4.3/bin/i686-linux
# Don't do anything if the toolchain is not there
ifneq (,$(strip $(wildcard $(HOST_SDK_TOOLCHAIN_PREFIX)-gcc)))
HOST_CC  := $(HOST_SDK_TOOLCHAIN_PREFIX)-gcc
HOST_CXX := $(HOST_SDK_TOOLCHAIN_PREFIX)-g++
HOST_AR  := $(HOST_SDK_TOOLCHAIN_PREFIX)-ar
endif # $(HOST_SDK_TOOLCHAIN_PREFIX)-gcc exists
endif # TARGET_PRODUCT == sdk

# We build everything in 32-bit, because some host tools are
# 32-bit-only anyway (emulator, acc), and because it gives us
# more consistency between the host tools and the target.
HOST_GLOBAL_CFLAGS += -m32
HOST_GLOBAL_LDFLAGS += -m32

HOST_GLOBAL_CFLAGS += -fPIC
HOST_GLOBAL_CFLAGS += \
	-include $(call select-android-config-h,linux-x86)

# Disable new longjmp in glibc 2.11 and later. See bug 2967937.
HOST_GLOBAL_CFLAGS += -D_FORTIFY_SOURCE=0

HOST_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined
