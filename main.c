#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#include "parser.h"

int main(void);
void parser(const struct parser_param *);
static void init_parser_param(struct parser_param *);
static void put(int, const char *, int, const char *, const char *, void *);
static int isnotfunction(const char *);
static void die(const char *, ...);
static void warning(const char *, ...);
static void message(const char *, ...);

int main(void) {
  struct parser_param pp;
  init_parser_param(&pp);
  parser(&pp);
  return 0;
}

void init_parser_param(struct parser_param *pp) {
  pp->size = 0;
  pp->flags = 0;
  pp->file = "node.js";
  pp->put = put;
  pp->arg = NULL;
  pp->isnotfunction = isnotfunction;
  pp->langmap = "JavaScript";
  pp->die = die;
  pp->warning = warning;
  pp->message = message;
}

void
put(int type,
    const char *tag,
    int lineno,
    const char *file,
    const char *line,
    void *arg) {
}

int isnotfunction(const char *tag) {
  return 0;
}

void die(const char *str, ...) {
  va_list v;
  va_start(v, str);
  vprintf(str, v);
  va_end(v);
  exit(EXIT_FAILURE);
}

void warning(const char *str, ...) {
  va_list v;
  va_start(v, str);
  vprintf(str, v);
  va_end(v);
}

void message(const char *str, ...) {
  va_list v;
  va_start(v, str);
  vprintf(str, v);
  va_end(v);
}
