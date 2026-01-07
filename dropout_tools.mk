HACK_PHDR := tool_bin/hack_phdr

DROPOUT_INCS := \
  dropout_utils.h \
  dropout_elf.h \
  dropout_arm32_align.h \
  dropout_seg.h
DROPOUT_SRCS := \
  utils.c \
  elf.c \
  align.c
DROPOUT_SHLIBS := \
  tool_bin/libdropout_utils.so \
  tool_bin/libdropout_elf.so \
  tool_bin/libdropout_arm32_align.so

$(HACK_PHDR): $(DROPOUT_INCS) $(DROPOUT_SRCS) hack_phdr.c $(DROPOUT_SHLIBS)
	@echo setup workdir and patch blob again >&2
	@exit 1
