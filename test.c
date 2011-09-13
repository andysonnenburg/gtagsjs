#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>

int main(int argc, const char *argv[]) {
  void *dl;
  if ((dl = dlopen(argv[1], RTLD_LAZY)) == NULL) {
    fputs(dlerror(), stderr);
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
