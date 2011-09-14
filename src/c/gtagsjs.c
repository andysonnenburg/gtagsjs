#include "config.h"

void gtagsjs_log(void (*)(const char *, ...), const char *);

void gtagsjs_log(void (*f)(const char *, ...), const char *str) {
  f(str);
}
