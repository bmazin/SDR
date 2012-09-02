/* 
 * PulseServer.c - Reads data in roach binary files and sends the data to a TCP client
 * usage: ./PulseServer process.bof
 *  process.bof is the name of the currently running firmware on the roach board
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
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>

#define STR_SIZE 100
#define TIMESTAMPER 0
#define DEBUG 1

void construct_path(const char*,int,char*);
void error(char*);
double wait_for_write_position(char* path_ptrfile,int wait_for_start,int* bool_first_half);
void toggle_trigger(char* path_triggerfile,int bool_start);
int make_connection(int server);
int start_server();
int get_process_id();
int send_packet(char* path_low_order_data,char* path_high_order_data,int client, int first_half_file);
//void sighandler(int sig);

int main(int argc, char* argv[])
{
    char str_proc[] = "/proc/";
    char path_ptrfile[STR_SIZE] = "/hw/ioreg/pulses_addr";
    char path_datafile0[STR_SIZE] = "/hw/ioreg/pulses_bram0";
    char path_datafile1[STR_SIZE] = "/hw/ioreg/pulses_bram1";
    char path_triggerfile[STR_SIZE] = "/hw/ioreg/startBuffer";
    int process_id = 0;
    int continue_current_session = 1;
    int packet_no = 0;
    double start_time;
    int no_interrupt = 1;
    int server,client;
	int first_half_file = 1;

    signal(SIGPIPE,SIG_IGN);
    process_id = get_process_id();

    construct_path(str_proc,process_id,path_ptrfile);
    construct_path(str_proc,process_id,path_datafile1);
    construct_path(str_proc,process_id,path_datafile0);
    construct_path(str_proc,process_id,path_triggerfile);

    server = start_server();
    while (no_interrupt == 1)
    {
        packet_no = 0;
        printf("Waiting for connection...\n");
		fflush(stdout);
        client = make_connection(server);
		printf("Connection made\n");
		fflush(stdout);

        toggle_trigger(path_triggerfile,1);
        //start_time = wait_for_write_position(path_ptrfile,1,&first_half_file);
        continue_current_session = 1;
		printf("Waiting for data to send\n");
		fflush(stdout);
        while (continue_current_session == 1)
        {
            wait_for_write_position(path_ptrfile,0,&first_half_file);
            printf("packet %d ",packet_no);
            if (send_packet(path_datafile0,path_datafile1,client,first_half_file) < 0 && errno == ECONNRESET)
            {
                perror("\nTCP connection reset by peer\n");
                printf("\nTCP connection reset by peer\n");
                continue_current_session = 0;
                errno = 0;
            }
            if (errno != 0)
			{
                perror("Error sending\n");
                printf("Error sending\n");
                continue_current_session = 0;
				no_interrupt = 0;
			}
            ++packet_no;
			fflush(stdout);
			fflush(stderr);
        }
        toggle_trigger(path_triggerfile,0);
        close(client);
        client = 0;
        printf("Session closed\n");
    }
    printf("Cleaning up\n");
    close(server);
	fflush(stdout);
	fflush(stderr);
    return 0; 
}

void construct_path(const char* path, int proc_id, char* rest)
{
     
     char str_temp[STR_SIZE];
     sprintf(str_temp,"%s%d%s",path,proc_id,rest);
     strcpy(rest,str_temp);
}

void error(char *msg) 
{
    perror(msg);
    exit(0);
}

double wait_for_write_position(char* path_ptrfile,int wait_for_start,int* bool_first_half)
{
    int time_to_stop = 0;
    uint32_t data_writing_ptr = -1;
	uint32_t data_writing_ptr_last = -1;
    uint32_t start_ptr = -1;
    uint32_t end_ptr = -1;
    int require_wrap = 0;
    const long FIRST_HALF = 8192;
    const long FIRST_HALF_ENDPTR = 8500;
    const long SECOND_HALF_ENDPTR = 300;
    FILE* ptrfile;
    struct timeval finish_tv;
    double finish_time;
    ptrfile = fopen(path_ptrfile,"rb");
    fseek(ptrfile,0,SEEK_SET);
    fread(&start_ptr,sizeof(uint32_t),1,ptrfile);
    fclose(ptrfile);
	if (errno != 0)
		error("error checking ptrfile\n");
    if (wait_for_start == 0)
    {
        if (start_ptr < FIRST_HALF)
        {
            end_ptr = FIRST_HALF_ENDPTR;
			*bool_first_half = 1;
        }
        else
        {
            end_ptr = SECOND_HALF_ENDPTR;
            require_wrap = 1;
			*bool_first_half = 0;
        }
    }
    else
    {
        end_ptr = start_ptr;
    }
	data_writing_ptr_last = start_ptr;
    while (time_to_stop == 0)
    {
        usleep(100);
        ptrfile = fopen(path_ptrfile,"rb");
		if (ptrfile < 0)
			error("ERROR opening ptrfile");
        if (fseek(ptrfile,0,SEEK_SET) < 0)
			error("ERROR seeking in ptrfile");
        if (fread(&data_writing_ptr,sizeof(uint32_t),1,ptrfile) < 0)
			error("ERROR reading ptrfile");
        fclose(ptrfile);
		if (DEBUG == 1 && data_writing_ptr-data_writing_ptr_last > 10)
		{
			data_writing_ptr_last = data_writing_ptr;
			printf("Accumulating file %d/8500\n",data_writing_ptr);
			fflush(stdout);
		}
        if (data_writing_ptr > end_ptr)
        {
            if (require_wrap == 0 || data_writing_ptr < FIRST_HALF)
                time_to_stop = 1;
        }
        
    }
    gettimeofday(&finish_tv,NULL);
    if (wait_for_start == 1)
        printf("Adr began incrementing at: %d.%06d\n",finish_tv.tv_sec,finish_tv.tv_usec);
    finish_time = finish_tv.tv_sec+finish_tv.tv_usec*1e-6;
    return finish_time;

}


void toggle_trigger(char*path_triggerfile,int bool_start)
{
    FILE* triggerfile;
    char trigger_buffer[] = {0x00,0x00,0x00,0x00};
    if (bool_start == 1)
        trigger_buffer[3] = 0x01;
    triggerfile = fopen(path_triggerfile,"wb");
    if (triggerfile < 0)
        error("ERROR opening trigger file");
    if (fwrite(trigger_buffer,sizeof(char),sizeof(trigger_buffer),triggerfile) != sizeof(trigger_buffer))
        error("ERROR writing to trigger file");
    fclose(triggerfile);
}

int get_process_id()
{
    int process_id = 0;
    int pid = 0;
    int bool_found_pid = 0;
    FILE* process_list;
    char line[STR_SIZE];
    char str_extension[STR_SIZE];
    char str_match_extension[] = "bof";
    process_list = popen("ps -eo pid,args","r");
    if (process_list < 0 || process_list == NULL)
        error("ERROR calling ps");
    while(fgets(line,STR_SIZE-1,process_list) != NULL && bool_found_pid == 0)
    {
        sscanf(line,"%d%*[^.]%*[.]%[bof]",&pid,str_extension);
        if (strcmp(str_extension,str_match_extension)==0)
        {
            process_id = pid;
            bool_found_pid = 1;
        }
    }
    printf("Firmware process: %d\n",process_id);
    if (bool_found_pid == 0)
    {
        error("ERROR finding firmware process ID\n");
    }
    return process_id;
}

int start_server()
{
    char host[]="";//empty string defaults to localhost
    int backlog = 1;//how many client sockets to allow to open per server socket
    int server;
    int portno = 50000;// + roachno;//$$ Change port number for roaches
    struct sockaddr_in serv_addr;
    server = socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) 
        error("ERROR opening socket");
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
    if (bind(server, (struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) 
        error("ERROR on binding");
    listen(server,backlog);
    return server;
}

int make_connection(int server)
{
    socklen_t clilen;   
    int client;
    struct sockaddr_in cli_addr;
    clilen = sizeof(cli_addr);
    client = accept(server, (struct sockaddr *) &cli_addr, &clilen);
    if (client < 0) 
        error("ERROR on accept");
    return client;
}

int send_packet(char* path_low_order_data,char* path_high_order_data,int client,int first_half_file)
{
    const int PACKET_LEN = 32768;
    char low_order_buffer[PACKET_LEN];
	char high_order_buffer[PACKET_LEN];
    FILE* low_order_datafile;
    FILE* high_order_datafile;
    int N_bytes_sent = 0;
    struct timeval start_tv;
    struct timeval end_tv;
    double start_time;
    double end_time;
    double duration;
	int i = 0;
	int seek_position = 0;
	int count_pixel0 = 0;
	char last_pixel = -1;
	int last_stamp = -1;
	int stamp = 0;
	int lost_packet_check = 1;
	if (first_half_file == 0)
		seek_position = PACKET_LEN;
    gettimeofday(&start_tv,NULL);
    low_order_datafile = fopen(path_low_order_data,"rb");
    fseek(low_order_datafile,seek_position,SEEK_SET);
    fread(low_order_buffer,sizeof(char),PACKET_LEN,low_order_datafile);
    fclose(low_order_datafile);
    N_bytes_sent = write(client,low_order_buffer,PACKET_LEN);
    if (N_bytes_sent != PACKET_LEN)
        return N_bytes_sent;
    high_order_datafile = fopen(path_high_order_data,"rb");
    fseek(high_order_datafile,seek_position,SEEK_SET);
    fread(high_order_buffer,sizeof(char),PACKET_LEN,high_order_datafile);
    fclose(high_order_datafile);
    N_bytes_sent = write(client,high_order_buffer,PACKET_LEN);
	if (errno == EPIPE)
	{
		errno = ECONNRESET;	
		return -1;
	}
    if (N_bytes_sent != PACKET_LEN) 
        return N_bytes_sent;
	for (i = 0; i < PACKET_LEN;i+=4)
	{
		if (high_order_buffer[i] == 0)
			count_pixel0++;
		//stamp = low_order_buffer[i+2]<<8+low_order_buffer[i+3];
		if (TIMESTAMPER == 1)
		{
			//lost_packet_check =((stamp & 0xfff)-(last_stamp & 0xfff) + 2501)%2501;
			//if (last_stamp != -1 && lost_packet_check != 1)
			//{
			//	printf("Skipped stamp from %x to %x\n",last_stamp,stamp);
			//}
			if (last_pixel != (char)(-1) && (high_order_buffer[i]-last_pixel)+256%256 != 1)
			{
				printf("Skipped from pixel %x to %x\n",last_pixel,high_order_buffer[i]);
			}
			//printf("%x %x %x %x\t%x %x %x %x\n",high_order_buffer[i],high_order_buffer[i+1],high_order_buffer[i+2],high_order_buffer[i+3],low_order_buffer[i],low_order_buffer[i+1],low_order_buffer[i+2],low_order_buffer[i+3]);
			//last_stamp = stamp;
		}
		last_pixel = high_order_buffer[i];
	}
    gettimeofday(&end_tv,NULL);
    start_time = start_tv.tv_sec+start_tv.tv_usec*1e-6;
    end_time = end_tv.tv_sec+end_tv.tv_usec*1e-6;
    printf("pixel %x at %.3f took %.3f\n",high_order_buffer[0],start_time,end_time-start_time);
    return N_bytes_sent;
}

