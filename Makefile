CFLAGS += -O2 -fPIC -g

STRINGS_XML := workdir/res/values-ja/strings.xml
LANG_FILE := workdir/assets/lang/en_US.lang
GAME_NATIVE := workdir/lib/armeabi-v7a/libminecraftpe.so
UNSIGNED_APK := workdir/dist/unsigned.apk

NATIVE_STRINGS := tool_bin/hardcoded.tsv
APKTOOL_YML := workdir/apktool.yml

all: $(UNSIGNED_APK)

include dropout_tools.mk

$(UNSIGNED_APK): workdir $(STRINGS_XML) $(LANG_FILE) $(HACK_PHDR) $(GAME_NATIVE)
	apktool b -o $(UNSIGNED_APK) workdir

$(STRINGS_XML): strings.xml
	mkdir -p workdir/res/values-ja
	cp strings.xml workdir/res/values-ja

$(LANG_FILE): tl.lang
	python merge_lang.py -o $(LANG_FILE) $(LANG_FILE) tl.lang

-include $(NATIVE_STRINGS).d

$(NATIVE_STRINGS): hardcoded.tsv.in $(CPPWRAP) $(READ_MCPE_VER) $(APKTOOL_YML)
	$(CPPWRAP) -DMCPE_$(shell $(READ_MCPE_VER) $(APKTOOL_YML)) -MD -MT $@ -MP -MF $@.d -o $@ $<

$(GAME_NATIVE): $(NATIVE_LOCALIZER) $(NATIVE_STRINGS)
	$(NATIVE_LOCALIZER) $(GAME_NATIVE) $(NATIVE_STRINGS)

clean:
	@echo note that this will not restore lang and game lib files
	$(call clean_dropout_tools)
	rm -f $(STRINGS_XML) \
		$(UNSIGNED_APK) \
		$(NATIVE_STRINGS) $(NATIVE_STRINGS).d

.PHONY: all clean
