#include <stdio.h>
#include <stdarg.h>

static int exec_cmd(char *cmd, ...)
{
    if (NULL == cmd) {
        return -1;
    }

    char str[1024];
    FILE *fp = NULL;
    va_list args;

    va_start(args, cmd);
    vsnprintf(str, sizeof(str), cmd, args);
    va_end(args);

    fp = popen(str, "w");
    if (NULL == fp) {
        return -1;
    }
    pclose(fp);

    return 0;
}

static int exec_cmd__get_print(char *recvBuf, unsigned int recvBufSize, char *cmd, ...)
{
    if (NULL == recvBuf || NULL == cmd) {
        return -1;
    }

    int ret;
    char str[1024];
    FILE *fp = NULL;
    va_list args;

    va_start(args, cmd);;
    vsnprintf(str, sizeof(str), cmd, args);
    va_end(args);

    fp = popen(str, "r");
    if (NULL == fp) {
        return -1;
    }
    ret = fread(recvBuf, 1, recvBufSize, fp);
    pclose(fp);

    if (0 >= ret) {
        if (0 != ferror(fp)) {
            return -1;
        }
        recvBuf[0] = '\0';// no output
        return 0;
    }
    recvBuf[ret] = '\0';

    return 0;
}

int main(int argc, char *argv[])
{
    exec_cmd("echo '%s=%d' > %s", "num", 100, "/tmp/test.txt");

    char recvBuf[1024];
    exec_cmd__get_print(recvBuf, sizeof(recvBuf), "cat %s", "/tmp/test.txt");
    printf("recvBuf: %s\n", recvBuf);

    return 0;
}

