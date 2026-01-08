#ifndef DROPOUT_UTILS_H
#define DROPOUT_UTILS_H

#include <stddef.h>

#define AUTO_CLO __attribute__((__cleanup__(fd_quit)))
#define AUTO_UNMAP __attribute__((__cleanup__(map_quit)))
#define AUTO_FREE __attribute__((__cleanup__(buf_quit)))

#define IN_VIEW(p_map, off) ((void *)((char *)(p_map)->view + (off)))

struct map_cfg
{
  void *view;
  size_t len;
};

void
fd_quit (int *);

void
map_quit (struct map_cfg *);

void
buf_quit (void **);

#endif /* DROPOUT_UTILS_H */
