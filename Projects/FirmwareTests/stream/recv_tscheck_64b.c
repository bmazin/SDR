/*
 * File:      recv_64b.c
 * Author:    Matt Strader
 * Date:      Jan 12, 2016
 * Firmware:  ctr_64b_gbe_2016_Jan_12_1653.fpg
 *
 * Compile with
 * cc recv_64b.c -o recv64
 * 
 * Mostly taken from https://www.abc.se/~m6695/udp.html
 * This receives udp packets.  It assumes that the packets each have
 * 100 64 bit counter values.  It counts any values that are missed
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdint.h>
#include <sys/time.h>
#include <signal.h>
#include <time.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFLEN 51200
#define NPACK 10000
#define PORT 50000
#define TSOFFS 1483228800

void diep(char *s)
{
  printf("errono: %d",errno);
  perror(s);
  exit(1);
}

struct hdrpacket
{
    unsigned long timestamp:36;
    unsigned int frame:12;
    unsigned int roach:8;
    unsigned int start:8;

}__attribute__((packed));;

int need_to_stop()//Checks for a stop file and returns true if found, else returns 0
{
    char stopfilename[] = "stop.bin";
    FILE* stopfile;
    stopfile = fopen(stopfilename,"r");
    if (stopfile == 0) //Don't stop
    {
        errno = 0;
        return 0;
    }
    else //Stop file exists, stop
    {
        printf("found stop file. Exiting\n");
        return 1;
    }
}

int main(void)
{
  struct sockaddr_in si_me, si_other;
  int s, i, slen=sizeof(si_other);
  unsigned char buf[BUFLEN];
  ssize_t nBytesReceived = 0;

  if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1)
    diep("socket");
  printf("socket created\n");
  fflush(stdout);

  memset((char *) &si_me, 0, sizeof(si_me));
  si_me.sin_family = AF_INET;
  si_me.sin_port = htons(PORT);
  si_me.sin_addr.s_addr = htonl(INADDR_ANY);
  if (bind(s, (const struct sockaddr *)(&si_me), sizeof(si_me))==-1)
      diep("bind");
  printf("socket bind\n");
  fflush(stdout);

  //Set receive buffer size, the default is too small.  
  //If the system will not allow this size buffer, you will need
  //to use sysctl to change the max buffer size
  int retval = 0;
  int bufferSize = 33554432;
  retval = setsockopt(s, SOL_SOCKET, SO_RCVBUF, &bufferSize, sizeof(bufferSize));
  if (retval == -1)
    diep("set receive buffer size");

  //Set recv to timeout after 3 secs
  const struct timeval sock_timeout={.tv_sec=3, .tv_usec=0};
  retval = setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (char*)&sock_timeout, sizeof(sock_timeout));
  if (retval == -1)
    diep("set receive buffer size");


  uint64_t pack = 0;
  uint64_t lastPack = 0;
  uint64_t packDiff = 0;
  uint64_t expectedPackDiff = 100;
  uint64_t nLostFrames = 0;
  uint64_t nFrames = 0;
  uint64_t roachTs = 0;
  uint64_t swp, swp1;
  unsigned long long sysTs;
  struct timeval tv;
  struct hdrpacket *hdr;
  FILE *timeFile = fopen("timetest.txt", "w");
  printf("sizof(ull) %d\n", sizeof(unsigned long long));

  while (need_to_stop() == 0)
  {
    if (nFrames % 10000 == 0)
    {
        printf("Frame %d Word %d\n",nFrames,pack);
    }
    //if (recvfrom(s, buf, BUFLEN, 0, &si_other, &slen)==-1)
    nBytesReceived = recv(s, buf, BUFLEN, 0);
    if (nBytesReceived == -1)
    {
      if (errno == EAGAIN || errno == EWOULDBLOCK)
      {// recv timed out, clear the error and check again
        errno = 0;
        continue;
      }
      else
        diep("recvfrom()");
    }
//    printf("Received packet from %s:%d\nData: %s\n\n", 
//           inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port), buf);
    //printf("Received %d bytes. Data: ",nBytesReceived);
    ++nFrames; 

    swp = *(uint64_t*)buf;
    swp1 = __bswap_64(swp);
    hdr = (struct hdrpacket *)&swp1;
    
    roachTs = hdr->timestamp;
    gettimeofday(&tv, NULL);
    sysTs = (unsigned long long)(tv.tv_sec)*1000 + (unsigned long long)(tv.tv_usec)/1000 - (unsigned long long)TSOFFS*1000;
    sysTs = sysTs*2;
    fprintf(timeFile, "%llu %llu\n", roachTs, sysTs);

    if ((packDiff > expectedPackDiff) && (pack != 0))
    {
        nLostFrames += packDiff/expectedPackDiff;
        printf("lost %d frames total of %d\n",nLostFrames,nFrames);
    }

    lastPack = pack;
  }

  printf("lost %d frames total of %d\n",nLostFrames,nFrames);
  close(s);
  return 0;
}
