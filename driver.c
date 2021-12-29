/*
 * Define macros to specify the standard C calling convention
 * The macros are designed so that they will work with all
 * supported C/C++ compilers.
 *
 * To use define your function prototype like this:
 *
 * return_type PRE_CDECL func_name( args ) POST_CDECL;
 *
 * For example:
 *
 * int PRE_CDECL f( int x, int y) POST_CDECL;
 */


#if defined(__GNUC__)
#  define PRE_CDECL
#  define POST_CDECL __attribute__((cdecl))
#else
#  define PRE_CDECL __cdecl
#  define POST_CDECL
#endif

#include <stdio.h>

int PRE_CDECL asm_main(int, char**) POST_CDECL;

int main(int argc, char* argv[])
{
  int ret_status;
  ret_status = asm_main(argc, argv);
  return ret_status;
}
