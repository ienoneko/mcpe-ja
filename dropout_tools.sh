if [ -z "$use_dropout_tools" ]; then
  echo 'this shell script is not for being executed directly!' >&2
  exit 1
fi

dropout_tools=dropout_tools.sh

mkdir -p tool_bin

function chk_rebuild_lib ()
{
  dropout_lib=tool_bin/$1
  dropout_src=$2
  dropout_inc=$3
  if [ ! -f $dropout_lib -o $dropout_inc -nt $dropout_lib -o $dropout_src -nt $dropout_lib -o $dropout_tools -nt $dropout_lib ]; then
    (set -x && cc -MD -MT $dropout_lib -MP -MF ${dropout_lib}.d -fPIC -O2 -g -shared -o $dropout_lib $dropout_src)
  fi
}

chk_rebuild_lib libdropout_utils.so \
  utils.c dropout_utils.h
chk_rebuild_lib libdropout_elf.so \
  elf.c dropout_elf.h
chk_rebuild_lib libdropout_arm32_align.so \
  align.c dropout_arm32_align.h
chk_rebuild_lib libdropout_csv.so \
  csv.c dropout_csv.h
chk_rebuild_lib libdropout_arg_list.so \
  arg_list.c dropout_arg_list.h
chk_rebuild_lib libdropout_addr_cvt.so \
  addr_conv.c dropout_addr_cvt.h
chk_rebuild_lib libdropout_strtab.so \
  strtab.c dropout_strtab.h

function rebuild_tool ()
{
  tool_obj=${1}.o
  tool_dep=${1}.d
  tool_src=$2
  (set -x && cc -MD -MT $tool_obj -MP -MF $tool_dep -fPIC -O2 -g -c -o $tool_obj $tool_src)
}

function chk_rebuild_tool ()
{
  tool_path=$1
  tool_obj=${1}.o
  tool_src=$2
  shift 2
  if [ ! -f $tool_obj -o $tool_src -nt $tool_obj -o $dropout_tools -nt $tool_obj ]; then
    rebuild_tool $tool_path $tool_src
  else
    for tool_inc in $@; do
      if [ $tool_inc -nt $tool_obj ]; then
        rebuild_tool $tool_path $tool_src
        break
      fi
    done
  fi
}

function relink_tool ()
{
  tool_path=$1
  tool_obj=${1}.o
  tool_ldlibs="$2"
  (set -x && cc -Ltool_bin -Wl,-rpath,\$ORIGIN $tool_ldlibs -o $tool_path $tool_obj)
}

function chk_relink_tool ()
{
  tool_path=$1
  tool_obj=${1}.o
  tool_ldlibs="$2"
  shift 2
  if [ ! -f $tool_path -o $tool_obj -nt $tool_path -o $dropout_tools -nt $tool_path ]; then
    relink_tool $tool_path "$tool_ldlibs"
  else
    for tool_shlib in $@; do
      if [ tool_bin/$tool_shlib -nt $tool_path ]; then
        relink_tool $tool_path "$tool_ldlibs"
        break
      fi
    done
  fi
}

HACK_PHDR=./tool_bin/hack_phdr
hackphdr_incs=(
  'dropout_utils.h'
  'dropout_elf.h'
  'dropout_arm32_align.h'
  'dropout_seg.h')
hackphdr_shlibs=(
  'libdropout_utils.so'
  'libdropout_elf.so'
  'libdropout_arm32_align.so')
hackphdr_ldlibs=\
-ldropout_utils\ \
-ldropout_elf\ \
-ldropout_arm32_align

chk_rebuild_tool $HACK_PHDR hack_phdr.c ${hackphdr_incs[@]}
chk_relink_tool $HACK_PHDR "$hackphdr_ldlibs" ${hackphdr_shlibs[@]}

NATIVE_LOCALIZER=./tool_bin/native_localizer
native_localizer_incs=(
  'dropout_csv.h'
  'dropout_arg_list.h'
  'dropout_elf.h'
  'dropout_seg.h'
  'dropout_arm32_align.h'
  'dropout_utils.h'
  'dropout_addr_cvt.h'
  'dropout_strtab.h'
)
native_localizer_shlibs=(
  'libdropout_csv.so'
  'libdropout_arg_list.so'
  'libdropout_elf.so'
  'libdropout_arm32_align.so'
  'libdropout_utils.so'
  'libdropout_addr_cvt.so'
  'libdropout_strtab.so'
)
native_localizer_ldlibs=\
-ldropout_csv\ \
-ldropout_arg_list\ \
-ldropout_elf\ \
-ldropout_arm32_align\ \
-ldropout_utils\ \
-ldropout_addr_cvt\ \
-ldropout_strtab

chk_rebuild_tool $NATIVE_LOCALIZER native_localizer.c ${native_localizer_incs[@]}
chk_relink_tool $NATIVE_LOCALIZER "$native_localizer_ldlibs" ${native_localizer_shlibs[@]}
