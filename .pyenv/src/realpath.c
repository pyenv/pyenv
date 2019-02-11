#include "bash.h"
#include <stdlib.h>
#include <stdio.h>

int realpath_builtin(list)
WORD_LIST *list;
{
	int es;
	char *realbuf, *p;

	if (list == 0) {
		// builtin_usage();
		return (EX_USAGE);
	}

	for (es = EXECUTION_SUCCESS; list; list = list->next) {
		p = list->word->word;
		realbuf = realpath(p, NULL);
		if (realbuf == NULL) {
			es = EXECUTION_FAILURE;
			// builtin_error("%s: cannot resolve: %s", p, strerror(errno));
		} else {
			printf("%s\n", realbuf);
			free(realbuf);
		}
	}
	return es;
}

char *realpath_doc[] = {
	"Display each PATHNAME argument, resolving symbolic links. The exit status",
	"is 0 if each PATHNAME was resolved; non-zero otherwise.",
	(char *)NULL
};

struct builtin realpath_struct = {
	"realpath",
	realpath_builtin,
	BUILTIN_ENABLED,
	realpath_doc,
	"realpath pathname [pathname...]",
	0
};
