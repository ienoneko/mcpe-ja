CPPWRAP := ./cpp_wrapper.sh
READ_MCPE_VER := ./read_mcpe_ver.sh

DROPOUT_CSV := tool_bin/libdropout_csv.so
DROPOUT_ARG_LIST := tool_bin/libdropout_arg_list.so
DROPOUT_ELF := tool_bin/libdropout_elf.so
DROPOUT_ARM32_ALIGN := tool_bin/libdropout_arm32_align.so
DROPOUT_UTILS := tool_bin/libdropout_utils.so
DROPOUT_ADDR_CVT := tool_bin/libdropout_addr_cvt.so
DROPOUT_STRTAB := tool_bin/libdropout_strtab.so

NATIVE_LOCALIZER := tool_bin/native_localizer
NATIVE_LOCALIZER_SHLIBS := \
  $(DROPOUT_CSV) \
  $(DROPOUT_ARG_LIST) \
  $(DROPOUT_ELF) \
  $(DROPOUT_ARM32_ALIGN) \
  $(DROPOUT_UTILS) \
  $(DROPOUT_ADDR_CVT) \
  $(DROPOUT_STRTAB)
NATIVE_LOCALIZER_LDLIBS := \
  -ldropout_csv \
  -ldropout_arg_list \
  -ldropout_elf \
  -ldropout_arm32_align \
  -ldropout_utils \
  -ldropout_addr_cvt \
  -ldropout_strtab

define shlib_rule_inner
-include $(1).d

$(1): $(2)
	$(CC) -MD -MT $$@ -MP -MF $$@.d $(CPPFLAGS) $(CFLAGS) -shared $(LDFLAGS) -o $$@ $$<
endef

define shlib_rule
$(eval $(call shlib_rule_inner,$(1),$(2)))
endef

define tool_rule_inner
-include $(1).d

$(1).o: $(2)
	$(CC) -MD -MT $$@ -MP -MF $(1).d $(CPPFLAGS) $(CFLAGS) -c -o $$@ $$<

$(1): $(1).o $(3)
	$(CC) -Ltool_bin -Wl,-rpath,\$$$$ORIGIN $(4) $(LDFLAGS) -o $$@ $$<
endef

define tool_rule
$(eval $(call tool_rule_inner,$(1),$(2),$(3),$(4)))
endef

define clean_shlib
rm -f $(1).d $(1)
endef

define clean_tool
rm -f $(1).o $(1).d $(1)
endef

include hack_phdr.mk

define clean_dropout_tools
$(call clean_shlib,$(DROPOUT_ARG_LIST))
$(call clean_shlib,$(DROPOUT_ARM32_ALIGN))
$(call clean_shlib,$(DROPOUT_CSV))
$(call clean_shlib,$(DROPOUT_ELF))
$(call clean_shlib,$(DROPOUT_UTILS))
$(call clean_shlib,$(DROPOUT_ADDR_CVT))
$(call clean_shlib,$(DROPOUT_STRTAB))

$(call clean_hackphdr)

$(call clean_tool,$(NATIVE_LOCALIZER))
endef

$(call shlib_rule,$(DROPOUT_CSV),csv.c)
$(call shlib_rule,$(DROPOUT_ARG_LIST),arg_list.c)
$(call shlib_rule,$(DROPOUT_ELF),elf.c)
$(call shlib_rule,$(DROPOUT_ARM32_ALIGN),align.c)
$(call shlib_rule,$(DROPOUT_UTILS),utils.c)
$(call shlib_rule,$(DROPOUT_ADDR_CVT),addr_conv.c)
$(call shlib_rule,$(DROPOUT_STRTAB),strtab.c)

$(call tool_rule,$(NATIVE_LOCALIZER),native_localizer.c,$(NATIVE_LOCALIZER_SHLIBS),$(NATIVE_LOCALIZER_LDLIBS))
