#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <syslog.h>
#include <stdarg.h>

#define log_err(fmt, args...)    __log(LOG_ERR,     __FILE__, __LINE__, fmt, ##args)
#define log_warn(fmt, args...)   __log(LOG_WARNING, __FILE__, __LINE__, fmt, ##args)
#define log_info(fmt, args...)   __log(LOG_INFO,    __FILE__, __LINE__, fmt, ##args)
#define log_debug(fmt, args...)  __log(LOG_DEBUG,   __FILE__, __LINE__, fmt, ##args)

static void __log(int level, const char *file, const int line, const char *fmt, ...)
{
    char str[1024];
    char tmp[1024];
    va_list ap;

    // original string format
    va_start(ap, fmt);
    vsnprintf(tmp, sizeof(tmp), fmt, ap);
    va_end(ap);

    // new string format
    switch (level) {
    case LOG_ERR:
        snprintf(str, sizeof(str), "[%s,%d]<err> %s", file, line, tmp);
        break;

    case LOG_WARNING:
        snprintf(str, sizeof(str), "[%s,%d]<warn> %s", file, line, tmp);
        break;

    case LOG_INFO:
        snprintf(str, sizeof(str), "[%s,%d]<info> %s", file, line, tmp);
        break;

    case LOG_DEBUG:
        snprintf(str, sizeof(str), "[%s,%d]<dbg> %s", file, line, tmp);
        break;

    default:
        return;
    }

    syslog(level, "%s", str);

    return;
}

int main(int argc, char *argv[])
{
    log_err("This is error test: %d.", 100);
    log_warn("This is warning test.");
    log_info("This is info test.");
    log_debug("This is debug test.");

    return 0;
}

