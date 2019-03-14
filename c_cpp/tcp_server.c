#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define SERVER_PORT    (9898)

int main(int argc, char *argv[])
{
	int ret;
	int fd;
	int recvLen, sendLen;
	char sendBuf[] = "This is message from server to test tcp";
	char recvBuf[1024];

	// 1. socket
	fd = socket(AF_INET, SOCK_STREAM, 0);// SOCK_STREAM for tcp
	if (-1 == fd) {
		printf("socket() fail: %s\n", strerror(errno));
		return -1;
	}

	// 2. bind
	struct sockaddr_in     saIn;              // struct sockaddr_in from [man 7 ip]
	saIn.sin_family      = AF_INET;           // always AF_INET
	saIn.sin_port        = htons(SERVER_PORT);// port in network byte order
	saIn.sin_addr.s_addr = htonl(INADDR_ANY); // address in network byte order

	ret = bind(fd, (struct sockaddr *)&saIn, sizeof(struct sockaddr_in));
	if (-1 == ret) {
		printf("bind() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	// 3. listen
	ret = listen(fd, 5);
	if (-1 == ret) {
		printf("listen() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	// 4. accept
	int tmp = sizeof(struct sockaddr_in);
	int acceptFd = accept(fd, (struct sockaddr *)&saIn, &tmp);
	if (-1 == acceptFd) {
		printf("accept() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	// 5. recv
	recvLen = recv(acceptFd, recvBuf, sizeof(recvBuf), 0); // use fd from accept()
	if (-1 == recvLen) {
		printf("recv() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	printf("recvLen = %d, recvBuf = %s\n", recvLen, recvBuf);

	// 6. send
	sendLen = send(acceptFd, sendBuf, sizeof(sendBuf), 0); // use fd from accept()
	if (-1 == sendLen) {
		printf("send() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	// 7. close
	close(fd);

	return 0;
}

