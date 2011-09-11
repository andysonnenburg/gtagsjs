#include <stdlib.h>

#include "HsFFI.h"

#ifdef __GLASGOW_HASKELL__
#include "Gtagsjs_stub.h"
#endif

#ifdef __GLASGOW_HASKELL__
extern void __stginit_Gtagsjs(void);
#endif

#include "parser.h"

void parser(const struct parser_param *);
static void gtagsjs_init(void) __attribute__((constructor));
static void gtagsjs_exit(void) __attribute__((destructor));

void parser(const struct parser_param *param) {
  gtagsjs_parser((HsPtr) param);
}

void gtagsjs_init(void) {
  int argc = 1;
  char* argv[] = {"gtagsjs", NULL};

  char** argp = argv;
  hs_init(&argc, &argp);
#ifdef __GLASGOW_HASKELL__
  hs_add_root(__stginit_Gtagsjs);
#endif
}

void gtagsjs_exit(void) {
  hs_exit();
}
