#include <string.h>

#include "dropout_elf.h"

int
mcpeja_chk_ehdr (Elf32_Ehdr *ehdr, size_t fsiz)
{
  if (fsiz < sizeof(Elf32_Ehdr)
      || memcmp (ehdr->e_ident, ELFMAG, SELFMAG)
      || ehdr->e_ident[EI_CLASS] != ELFCLASS32
      || ehdr->e_ident[EI_DATA] != ELFDATA2LSB
      || ehdr->e_ident[EI_VERSION] != EV_CURRENT
      || ehdr->e_ident[EI_OSABI] != ELFOSABI_SYSV
      || ehdr->e_ident[EI_ABIVERSION] > 0
      || ({ int n = EI_NIDENT - EI_PAD; for (unsigned char *c = &ehdr->e_ident[EI_PAD]; n; n--) if (*c++) break; n; })
      || ehdr->e_type != ET_DYN
      || ehdr->e_machine != EM_ARM
      || ehdr->e_version != EV_CURRENT
      || ehdr->e_entry != 0
      || ehdr->e_ehsize != sizeof(Elf32_Ehdr)
      || ehdr->e_phentsize != sizeof(Elf32_Phdr)
      || fsiz < ehdr->e_phoff + ehdr->e_phnum * sizeof(Elf32_Phdr))
    return -1;

  return 0;
}
