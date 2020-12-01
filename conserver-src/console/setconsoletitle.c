#ifdef __CYGWIN__
#include <windows.h>
#endif /* __CYGWIN__ */

#include "setconsoletitle.h"

void set_console_title(const char* title)
{
#ifdef __CYGWIN__
	SetConsoleTitle(title);
#endif /* __CYGWIN__ */
}