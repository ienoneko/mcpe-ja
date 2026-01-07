#include "dropout_arm32_align.h"

#define ARM32_DATA_MISALIGNMENT_MASK 0b011
#define ARM32_ALIGN_DATA_MASK 0b11111111111111111111111111111100

#define ARM32_SEG_MISALIGNMENT_MASK 0x0fff
#define ARM32_ALIGN_SEG_MASK 0xfffff000

uint32_t
arm32_align_data (uint32_t base)
{
  int remainder;

  remainder = base & ARM32_DATA_MISALIGNMENT_MASK;
  if (!remainder)
    return base;

  return (base & ARM32_ALIGN_DATA_MASK) + ARM32_DATA_ALIGNMENT;
}

uint32_t
arm32_align_seg (uint32_t base, uint32_t foff)
{
  int remainder_base;
  int remainder_foff;

  remainder_base = base & ARM32_SEG_MISALIGNMENT_MASK;
  if (remainder_base)
    base = (base & ARM32_ALIGN_SEG_MASK) + ARM32_SEG_ALIGNMENT;

  remainder_foff = foff & ARM32_SEG_MISALIGNMENT_MASK;
  if (remainder_foff)
    base += remainder_foff;

  return base;
}
