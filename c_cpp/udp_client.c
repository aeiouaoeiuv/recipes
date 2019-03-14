#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define SERVER_IPV4    ("127.0.0.1")
#define SERVER_PORT    (8989)

unsigned int ipv4_str_2_net(char *ipv4)
{
	int ret;
	unsigned int netIp = 0;

	ret = inet_pton(AF_INET, ipv4, &netIp);
	if (1 == ret) {
		return netIp;
	}
	else if (0 == ret) {
		printf("%s incorrect\n", ipv4);
	}
	else {
		printf("error occur: %d,%s\n", errno, strerror(errno));
	}

	return 0;
}

int main(int argc, char *argv[])
{
	int ret;
	int fd;
	int recvLen, sendLen;
	char sendBuf[] = "This is message from client";
	char recvBuf[1024];

	// 1. socket
	fd = socket(AF_INET, SOCK_DGRAM, 0);// SOCK_DGRAM for udp
	if (-1 == fd) {
		printf("socket() fail: %s\n", strerror(errno));
		return -1;
	}

	struct sockaddr_in     saIn;                        // struct sockaddr_in from [man 7 ip]
	saIn.sin_family      = AF_INET;                     // always AF_INET
	saIn.sin_port        = htons(SERVER_PORT);          // port in network byte order
	saIn.sin_addr.s_addr = ipv4_str_2_net(SERVER_IPV4); // address in network byte order

	// 2. sendto
	sendLen = sendto(fd, sendBuf, sizeof(sendBuf), 0, (struct sockaddr *)&saIn, sizeof(struct sockaddr_in));
	if (-1 == sendLen) {
		printf("sendto() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	// 3. recvfrom
	int tmp = sizeof(struct sockaddr_in);
	recvLen = recvfrom(fd, recvBuf, sizeof(recvBuf), 0, (struct sockaddr *)&saIn, &tmp);
	if (-1 == recvLen) {
		printf("recvfrom() fail: %s\n", strerror(errno));
		close(fd);
		return -1;
	}

	printf("recvLen = %d, recvBuf = %s\n", recvLen, recvBuf);

	// 5. close
	close(fd);

	return 0;
}

