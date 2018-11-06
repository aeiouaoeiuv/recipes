#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


void ipv4_str_2_net(char *ipv4)
{
	unsigned int netIp = inet_addr(ipv4);
	printf("net ip=0x%X\n", netIp);
}

void ipv4_net_2_str(unsigned int netIpv4)
{
	struct in_addr stAddr;
	char strIpv4[32];

	stAddr.s_addr = (in_addr_t)netIpv4;
	snprintf(strIpv4, sizeof(strIpv4), "%s", inet_ntoa(stAddr));

	printf("str ip=%s\n", strIpv4);
}

int main(int argc, char *argv[])
{
	char strIpv4[] = "192.168.100.200";
	unsigned int netIpv4 = 0xC964A8C0;

	ipv4_str_2_net(strIpv4);

	ipv4_net_2_str(netIpv4);

	return 0;
}

