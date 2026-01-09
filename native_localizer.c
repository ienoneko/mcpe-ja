#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "dropout_addr_cvt.h"
#include "dropout_arg_list.h"
#include "dropout_arm32_align.h"
#include "dropout_csv.h"
#include "dropout_elf.h"
#include "dropout_seg.h"
#include "dropout_strtab.h"
#include "dropout_utils.h"

int
main (int argc, char **argv)
{
  AUTO_CLO int fd = -1;
  struct stat fi;
  size_t fsiz;
  AUTO_UNMAP struct map_cfg map = {
    .view = MAP_FAILED,
  };
  Elf32_Ehdr *ehdr;

  if (argc != 3)
  {
usage:
    fprintf (stderr, "Usage: %s <path to shared object> <path to string list>\n", argv[0]);
    return 1;
  }

  fd = open (argv[1], O_RDWR);
  if (fd < 0)
    goto usage;

  if (fstat (fd, &fi) < 0)
  {
    perror ("fstat");
    return 1;
  }

  fsiz = fi.st_size;

  map.view = mmap (NULL, fsiz, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (map.view == MAP_FAILED)
  {
    perror ("mmap");
    return 1;
  }

  map.len = fsiz;

  ehdr = IN_VIEW(&map, 0x0);
  if (mcpeja_chk_ehdr (ehdr, fsiz) < 0)
    goto usage;
}
