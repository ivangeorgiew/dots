// Needed imports are
//#include <stdio.h>
//#include <errno.h>
//#include <string.h>
//
// Command to replace every function call in vim:
// %s/\([a-zA-Z0-9]\s*\)\@<![ \t,(]\(if\|switch\|for\|sizeof\)\@!\zs\([a-z_*][a-zA-Z0-9_]\+(\([^(]*([^()]*)[^)]*\|[^()]*\)*)\)/ERR_CATCH(\3)/g

// Macro for catching errors - use it by surrounding function calls - ERROR_CATCH(someFunc(a, b))
#define ERROR_CATCH(func) ({ \
    errno = 0; \
    const char *func_name = #func; \
    const int func_result = (func); \
    if(errno != 0) { \
        fprintf(stderr, "ERROR_%d at [File: %s, Line: %d, Func: %s] -- %s\n", errno, __FILE__, __LINE__, func_name, strerror(errno)); \
        errno = 0; \
    } \
    func_result; \
})
