HACK_PHDR := tool_bin/hack_phdr

HACKPHDR_SHLIBS := \
  $(DROPOUT_UTILS) \
  $(DROPOUT_ELF) \
  $(DROPOUT_ARM32_ALIGN)

-include $(HACK_PDHR).d

define clean_hackphdr
$(call clean_tool,$(HACK_PHDR))
endef

$(HACK_PHDR): $(HACK_PHDR).o $(HACKPHDR_SHLIBS)
	@echo setup workdir and patch blob again >&2
	@exit 1
