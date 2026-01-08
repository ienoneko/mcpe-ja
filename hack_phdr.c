#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#include "dropout_arm32_align.h"
#include "dropout_elf.h"
#include "dropout_seg.h"
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
  int nphdr;
  int nphdrnew;
  size_t newphtsiz;
  AUTO_FREE void *phtbuf = NULL;
  Elf32_Phdr *newphdr;
  Elf32_Phdr *pht_phdr;
  uint32_t free_vaddr;
  Elf32_Phdr *phdr;
  uint32_t seg_end;
  off_t new_phoff;
  off_t newfsiz;
  size_t dropout_seg_siz;
  uint32_t dropout_vbase;

  if (argc != 2)
  {
usage:
    fprintf (stderr, "Usage: %s <path to shared object>\n", argv[0]);
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
  if (mcpeja_chk_ehdr (ehdr, fsiz))
    goto usage;

  nphdr = ehdr->e_phnum;
  nphdrnew = nphdr + 1;
  newphtsiz = nphdrnew * sizeof(Elf32_Phdr);

  phtbuf = malloc (newphtsiz);
  if (!phtbuf)
  {
    perror ("malloc");
    return 1;
  }

  newphdr = phtbuf;
  pht_phdr = NULL;
  free_vaddr = 0;

  for (phdr = IN_VIEW(&map, ehdr->e_phoff); nphdr; nphdr--)
  {
    switch (phdr->p_type)
    {
      case PT_PHDR:
        if (pht_phdr)
          goto usage;

        pht_phdr = newphdr;
        break;

      case PT_LOAD:
        seg_end = phdr->p_vaddr + phdr->p_memsz;
        if (seg_end > free_vaddr)
          free_vaddr = seg_end;

      default:
        memcpy (newphdr, phdr, sizeof(Elf32_Phdr));
        break;
    }

    phdr++;
    newphdr++;
  }

  new_phoff = arm32_align_data (fsiz + DROPOUT_SIZ);
  newfsiz = new_phoff + newphtsiz;

  if (ftruncate (fd, newfsiz) < 0)
  {
    perror ("ftruncate");
    return 1;
  }

  if (lseek (fd, fsiz, SEEK_SET) != fsiz)
  {
    fprintf (stderr, "cannot seek to seg region\n");
    return 1;
  }

  if (write (fd, DROPOUT_SEG_MAG, DROPOUT_SEG_NMAG) != DROPOUT_SEG_NMAG)
  {
    fprintf (stderr, "cannot write seg magic\n");
    return 1;
  }

  dropout_seg_siz = newfsiz - fsiz;
  dropout_vbase = arm32_align_seg (free_vaddr, fsiz);

  newphdr->p_type = PT_LOAD;
  newphdr->p_flags = PF_R;
  newphdr->p_align = ARM32_SEG_ALIGNMENT;
  newphdr->p_offset = fsiz;
  newphdr->p_filesz = newphdr->p_memsz = dropout_seg_siz;
  newphdr->p_vaddr = newphdr->p_paddr = dropout_vbase;

  if (pht_phdr)
  {
    pht_phdr->p_type = PT_PHDR;
    pht_phdr->p_flags = PF_R;
    pht_phdr->p_align = ARM32_DATA_ALIGNMENT;
    pht_phdr->p_offset = new_phoff;
    pht_phdr->p_filesz = pht_phdr->p_memsz = newphtsiz;
    pht_phdr->p_vaddr = pht_phdr->p_paddr = dropout_vbase + dropout_seg_siz - newphtsiz;
  }

  if (lseek (fd, new_phoff, SEEK_SET) != new_phoff)
  {
    fprintf (stderr, "cannot seek to new pht region\n");
    return 1;
  }

  if (write (fd, phtbuf, newphtsiz) != newphtsiz)
  {
    fprintf (stderr, "cannot write new pht");
    return 1;
  }

  ehdr->e_phoff = new_phoff;
  ehdr->e_phnum = nphdrnew;
}
