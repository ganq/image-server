# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := libjpeg
DEFS_Debug := '-DDYNAMIC_ANNOTATIONS_ENABLED=1' \
	'-D_DEBUG'

# Flags passed to both C and C++ files.
CFLAGS_Debug := -pthread \
	-fno-exceptions \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-fno-strict-aliasing \
	-O0 \
	-g

# Flags passed to only C (and not C++) files.
CFLAGS_C_Debug := 

# Flags passed to only C++ (and not C) files.
CFLAGS_CC_Debug := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden

INCS_Debug := -Ithird_party/chromium/src

DEFS_Release := '-DNDEBUG'

# Flags passed to both C and C++ files.
CFLAGS_Release := -pthread \
	-fno-exceptions \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-fno-strict-aliasing \
	-O2 \
	-fno-ident \
	-fdata-sections \
	-ffunction-sections \
	-fno-asynchronous-unwind-tables

# Flags passed to only C (and not C++) files.
CFLAGS_C_Release := 

# Flags passed to only C++ (and not C) files.
CFLAGS_CC_Release := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden

INCS_Release := -Ithird_party/chromium/src

OBJS := $(obj).target/$(TARGET)/third_party/libjpeg/jcapimin.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcapistd.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jccoefct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jccolor.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcdctmgr.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jchuff.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcinit.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcmainct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcmarker.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcmaster.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcomapi.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcparam.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcphuff.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcprepct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jcsample.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdapimin.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdapistd.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdatadst.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdatasrc.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdcoefct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdcolor.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jddctmgr.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdhuff.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdinput.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdmainct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdmarker.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdmaster.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdmerge.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdphuff.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdpostct.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jdsample.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jerror.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jfdctflt.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jfdctfst.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jfdctint.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jidctflt.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jidctfst.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jidctint.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jmemmgr.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jmemnobs.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jquant1.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jquant2.o \
	$(obj).target/$(TARGET)/third_party/libjpeg/jutils.o

# Add to the list of files we specially track dependencies for.
all_deps += $(OBJS)

# CFLAGS et al overrides must be target-local.
# See "Target-specific Variable Values" in the GNU Make manual.
$(OBJS): TOOLSET := $(TOOLSET)
$(OBJS): GYP_CFLAGS := $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_C_$(BUILDTYPE)) $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))
$(OBJS): GYP_CXXFLAGS := $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_CC_$(BUILDTYPE)) $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))

# Suffix rules, putting all outputs into $(obj).

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(srcdir)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# Try building from generated source, too.

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj).$(TOOLSET)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# End of this set of suffix rules
### Rules for final target.
LDFLAGS_Debug := -pthread \
	-Wl,-z,noexecstack \
	-rdynamic

LDFLAGS_Release := -pthread \
	-Wl,-z,noexecstack \
	-Wl,--gc-sections

LIBS := 

$(obj).target/third_party/libjpeg/libjpeg.a: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(obj).target/third_party/libjpeg/libjpeg.a: LIBS := $(LIBS)
$(obj).target/third_party/libjpeg/libjpeg.a: TOOLSET := $(TOOLSET)
$(obj).target/third_party/libjpeg/libjpeg.a: $(OBJS) FORCE_DO_CMD
	$(call do_cmd,alink)

all_deps += $(obj).target/third_party/libjpeg/libjpeg.a
# Add target alias
.PHONY: libjpeg
libjpeg: $(obj).target/third_party/libjpeg/libjpeg.a

# Add target alias to "all" target.
.PHONY: all
all: libjpeg

