#include <sys/mman.h>
#include <unistd.h>

#include "dropout_utils.h"

void
fd_quit (int *p_fd)
{
  int fd;

  fd = *p_fd;
  if (fd < 0)
    return;

  close (fd);
}

void
map_quit (struct map_cfg *p_map)
{
  if (p_map->view == MAP_FAILED)
    return;

  munmap (p_map->view, p_map->len);
}
