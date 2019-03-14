#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

void ipv4_str_2_net(char *ipv4)
{
	int ret;
	unsigned int netIp;

	ret = inet_pton(AF_INET, ipv4, &netIp);
	if (1 == ret) {
		printf("%s to network byte order is: 0x%X\n", ipv4, netIp);
	}
	else if (0 == ret) {
		printf("%s incorrect\n", ipv4);
	}
	else {
		printf("error occur: %d,%s\n", errno, strerror(errno));
	}

	return;
}

void ipv4_net_2_str(unsigned int netIp)
{
	struct in_addr inAddr;

	inAddr.s_addr = netIp;
	printf("0x%X to character string is: %s\n", netIp, inet_ntoa(inAddr));

	return;
}

int main(int argc, char *argv[])
{
	// character string to network byte order
	ipv4_str_2_net((char *)"192.168.100.200");

	// network byte order to character string
	ipv4_net_2_str(0xC964A8C0);

	return 0;
}

