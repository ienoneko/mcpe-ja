STRINGS_XML := workdir/res/values-ja/strings.xml
LANG_FILE := workdir/assets/lang/en_US.lang
UNSIGNED_APK := workdir/dist/unsigned.apk

$(UNSIGNED_APK): workdir $(STRINGS_XML) $(LANG_FILE)
	apktool b -o $(UNSIGNED_APK) workdir

$(STRINGS_XML): strings.xml
	mkdir -p workdir/res/values-ja
	cp strings.xml workdir/res/values-ja

$(LANG_FILE): tl.lang
	python merge_lang.py -o $(LANG_FILE) $(LANG_FILE) tl.lang
