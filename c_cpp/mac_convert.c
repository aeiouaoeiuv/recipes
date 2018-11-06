#include <stdio.h>

void mac_str_2_byte(char *strMac)
{
	unsigned int byteMac[6];
	sscanf(strMac, "%02x:%02x:%02x:%02x:%02x:%02x", &byteMac[0], &byteMac[1], &byteMac[2], &byteMac[3], &byteMac[4], &byteMac[5]);

	printf("byte mac=%02x:%02x:%02x:%02x:%02x:%02x\n", byteMac[0], byteMac[1], byteMac[2], byteMac[3], byteMac[4], byteMac[5]);
}

void mac_byte_2_str(unsigned int *byteMac)
{
	char strMac[32];

	snprintf(strMac, sizeof(strMac), "%02x:%02x:%02x:%02x:%02x:%02x", byteMac[0], byteMac[1], byteMac[2], byteMac[3], byteMac[4], byteMac[5]);
	printf("str mac=%s\n", strMac);
}

int main(int argc, char *argv[])
{
	char strMac[] = "11:22:33:44:55:66";
	unsigned int byteMac[] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF};

	mac_str_2_byte(strMac);

	mac_byte_2_str(byteMac);

	return 0;
}

