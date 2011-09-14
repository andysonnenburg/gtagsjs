#include "config.h"

#include <stdlib.h>

#include "HsFFI.h"

#ifdef __GLASGOW_HASKELL__
#include "Gtagsjs_stub.h"
#endif

#ifdef __GLASGOW_HASKELL__
extern void GTAGSJS_ROOT(void);
#endif

static void gtagsjs_init(void) __attribute__((constructor));
static void gtagsjs_exit(void) __attribute__((destructor));

void gtagsjs_init(void) {
  int argc = 1;
  char* argv[] = {"gtagsjs", NULL};

  char** argp = argv;
  hs_init(&argc, &argp);
#ifdef __GLASGOW_HASKELL__
  hs_add_root(GTAGSJS_ROOT);
#endif
}

void gtagsjs_exit(void) {
  hs_exit();
}
