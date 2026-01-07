#ifndef DROPOUT_ELF_H
#define DROPOUT_ELF_H

#include <elf.h>
#include <stddef.h>

int
mcpeja_chk_ehdr (Elf32_Ehdr *ehdr, size_t fsiz);

#endif /* DROPOUT_ELF_H */
