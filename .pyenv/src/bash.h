#ifndef __BASH_H__
#define __BASH_H__

#define EXECUTION_SUCCESS 0
#define EXECUTION_FAILURE 1
#define EX_USAGE 258

#define BUILTIN_ENABLED 1

typedef struct word_desc {
  char *word;
  int flags;
} WORD_DESC;

typedef struct word_list {
  struct word_list *next;
  WORD_DESC *word;
} WORD_LIST;

typedef int sh_builtin_func_t(WORD_LIST *);

struct builtin {
  char *name;
  sh_builtin_func_t *function;
  int flags;
  char * const *long_doc;
  const char *short_doc;
  char *unused;
};

#endif
