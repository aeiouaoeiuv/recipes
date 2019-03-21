#include <stdio.h>
#include <stdarg.h>
#include <sys/wait.h>

static int exec_cmd(char *cmd, ...)
{
    if (NULL == cmd) {
        return -1;
    }

    int ret;
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

    // check [man 2 wait] for more options
    ret = pclose(fp);
    if (WIFEXITED(ret)) {// returns true if the child terminated normally
        if (0 != WEXITSTATUS(ret)) {// unequal 0 maybe success, depend on the command
            printf("this cmd(%s) return %d, maybe exec fail\n", str, WEXITSTATUS(ret));
        }
        return 0;
    }
    else if (WIFSIGNALED(ret)) {// returns true if the child process was terminated by a signal
        printf("this cmd(%s) was terminated by a signal\n", str);
        return 1;
    }

    printf("unknown error: 0x%x\n", ret);
    return 1;
}

static int exec_cmd__get_print(char *recvBuf, unsigned int recvBufSize, char *cmd, ...)
{
    if (NULL == recvBuf || NULL == cmd) {
        return -1;
    }

    int ret, len;
    char str[1024];
    FILE *fp = NULL;
    va_list args;

    va_start(args, cmd);
    vsnprintf(str, sizeof(str), cmd, args);
    va_end(args);

    fp = popen(str, "r");
    if (NULL == fp) {
        return -1;
    }
    len = fread(recvBuf, 1, recvBufSize, fp);

    // check [man 2 wait] for more options
    ret = pclose(fp);
    if (WIFEXITED(ret)) {// returns true if the child terminated normally
        if (0 != WEXITSTATUS(ret)) {// unequal 0 maybe success, depend on the command
            printf("this cmd(%s) return %d, maybe exec fail\n", str, WEXITSTATUS(ret));
        }

        // return printed data
        if (0 >= len) {
            if (0 != ferror(fp)) {
                return -1;
            }
            recvBuf[0] = '\0';// no output
            return 0;
        }
        recvBuf[len] = '\0';

        return 0;
    }
    else if (WIFSIGNALED(ret)) {// returns true if the child process was terminated by a signal
        printf("this cmd(%s) was terminated by a signal\n", str);
        return 1;
    }

    printf("unknown error: 0x%x\n", ret);
    return 1;
}

int main(int argc, char *argv[])
{
    exec_cmd("echo '%s=%d' > %s", "num", 100, "/tmp/test.txt");

    char recvBuf[1024];
    exec_cmd__get_print(recvBuf, sizeof(recvBuf), "cat %s", "/tmp/test.txt");
    printf("recvBuf: %s\n", recvBuf);

    return 0;
}

