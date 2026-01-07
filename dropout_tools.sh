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
    (set -x && cc -fPIC -O2 -g -shared -o $dropout_lib $dropout_src)
  fi
}

chk_rebuild_lib libdropout_utils.so \
  utils.c dropout_utils.h
chk_rebuild_lib libdropout_elf.so \
  elf.c dropout_elf.h
chk_rebuild_lib libdropout_arm32_align.so \
  align.c dropout_arm32_align.h

HACK_PHDR_OBJ=tool_bin/hack_phdr.o
function rebuild_hackphdr ()
{
  (set -x && cc -fPIC -O2 -g -c -o $HACK_PHDR_OBJ hack_phdr.c)
}

dropout_incs=(
  'dropout_utils.h'
  'dropout_elf.h'
  'dropout_arm32_align.h'
  'dropout_seg.h')

if [ ! -f $HACK_PHDR_OBJ -o hack_phdr.c -nt $HACK_PHDR_OBJ -o $dropout_tools -nt $HACK_PHDR_OBJ ]; then
  rebuild_hackphdr
else
  for dropout_inc in "${dropout_incs[@]}"; do
    if [ $dropout_inc -nt $HACK_PHDR_OBJ ]; then
      rebuild_hackphdr
      break
    fi
  done
fi

HACK_PHDR=./tool_bin/hack_phdr
function relink_hackphdr ()
{
  (set -x && cc -Ltool_bin \
    -Wl,-rpath,\$ORIGIN \
    -ldropout_utils \
    -ldropout_elf \
    -ldropout_arm32_align \
    -o $HACK_PHDR $HACK_PHDR_OBJ)
}

dropout_shlibs=(
  'libdropout_utils.so'
  'libdropout_elf.so'
  'libdropout_arm32_align.so')

if [ ! -f $HACK_PHDR -o $HACK_PHDR_OBJ -nt $HACK_PHDR -o $dropout_tools -nt $HACK_PHDR ]; then
  relink_hackphdr
else
  for dropout_shlib in "${dropout_shlibs[@]}"; do
    if [ tool_bin/$dropout_shlib -nt $HACK_PHDR ]; then
      relink_hackphdr
      break
    fi
  done
fi
