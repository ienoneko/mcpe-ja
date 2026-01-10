#ifndef DROPOUT_ELF_H
#define DROPOUT_ELF_H

#include <elf.h>
#include <stddef.h>

#if defined(DROPOUT_ELF64)
#define Elfxx_Ehdr Elf64_Ehdr
#define Elfxx_Phdr Elf64_Phdr
#define ELFCLASSxx ELFCLASS64
#else
#define Elfxx_Ehdr Elf32_Ehdr
#define Elfxx_Phdr Elf32_Phdr
#define ELFCLASSxx ELFCLASS32
#endif

#if defined(MCPE_X86)
#define EM_xxx EM_386
#else
#define EM_xxx EM_ARM
#endif

int
mcpeja_chk_ehdr (Elfxx_Ehdr *ehdr, size_t fsiz);

#endif /* DROPOUT_ELF_H */
