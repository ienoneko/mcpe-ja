/*
 * note that despite the name, this should also work for x86
 */

#ifndef DROPOUT_ARM32_ALIGN_H
#define DROPOUT_ARM32_ALIGN_H

#include <stdint.h>

#define ARM32_DATA_ALIGNMENT 4
#define ARM32_SEG_ALIGNMENT 0x1000

uint32_t
arm32_align_data (uint32_t base);

uint32_t
arm32_align_seg (uint32_t base, uint32_t foff);

#endif /* DROPOUT_ARM32_ALIGN_H */
