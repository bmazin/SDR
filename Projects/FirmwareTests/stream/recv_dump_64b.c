/*
 * File:      recv_dump_64b.c
 * Author:    Matt Strader
 * Date:      Feb 18, 2016
 * Firmware:  pgbe0_2016_Feb_16_1906.fpg
 *
 * Compile with
 * cc recv_dump_64b.c -o recv64
 * 
 * Mostly taken from https://www.abc.se/~m6695/udp.html
 * This receives udp packets and dumps them to a file
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
#define PORT 50000

void diep(char *s)
{
  printf("errono: %d",errno);
  perror(s);
  exit(1);
}

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
  //set up a socket connection
  struct sockaddr_in si_me, si_other;
  int s, i, slen=sizeof(si_other);
  unsigned char buf[BUFLEN];
  ssize_t nBytesReceived = 0;
  ssize_t nTotalBytes = 0;

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

  uint64_t nFrames = 0;

  FILE* dump_file;
  dump_file = fopen("photonDump.bin","ab");
  while (need_to_stop() == 0)
  {
    if (nFrames % 1000 == 0)
    {
        printf("Frame %d\n",nFrames);
    }
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
    nTotalBytes += nBytesReceived;
//    printf("Received packet from %s:%d\nData: %s\n\n", 
//           inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port), buf);
    //printf("Received %d bytes. Data: ",nBytesReceived);
    ++nFrames; 
    fwrite(buf,sizeof(char),nBytesReceived,dump_file);

    /*
    pack = buf[7]+(buf[6]<<8)+(buf[5]<<16)+(buf[4]<<24)+((uint64_t)buf[3]<<32)+((uint64_t)buf[2]<<40)+((uint64_t)buf[1]<<48)+((uint64_t)buf[0]<<56);
    packDiff = pack - lastPack;
    if ((packDiff > expectedPackDiff) && (pack != 0))
    {
        nLostFrames += packDiff/expectedPackDiff;
        printf("lost %d frames total of %d\n",nLostFrames,nFrames);
    }

    lastPack = pack;
    */
  }

  fclose(dump_file);
  printf("received %d frames, %d bytes\n",nFrames,nTotalBytes);
  close(s);
  return 0;
}
