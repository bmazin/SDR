/* 
 * PacketMaster.c - A TCP client to pull data down off the ROACH boards and store them in
 *  a pre-existing h5 VLArray file
 * To compile: h5cc -shlib -pthread -o PPM PulsePacketMaster.c
 * Usage: ./PPM
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
#include "hdf5.h"
#include "hdf5_hl.h"

//max number of characters in all strings
#define STR_SIZE 80 
//number of rows in the final quicklook images
#define BEAM_ROWS 32
//number of columns in the final quicklook images
#define BEAM_COLS 32
//number of dimensions in the Variable Length array (VLarray).  
//There is a 1D array of pointers to variable length arrays, so rank=1
#define DATA_RANK 1
//The number of bytes read from a roach at a time
#define BUFSIZE 32768
//the number of uint32_t in a buffer read from a roach
#define BUFSIZE_INTS 8192

//when set =1, data from timestamper.bof will be used to check for lost packets
#define TIMESTAMPER 0

//change number of roaches here and adjust hostnames in connect_to_roach()
#define NROACHES 4
//The number of channels or pixels corresponding to each roach
#define NPIXELS_PER_ROACH 256
//max number of possible photon counts in a second of data for a pixel 
#define MAX_EVENTS_PER_SEC 2500

void append_path(const char* path, char* rest);//creates a relative file path from pwd to a filename
void add_group_attrs(hid_t group);//adds attributes to an H5 group so that it's readable by PyTables
void add_dataset_attrs(hid_t dataset);//adds attributes to an H5 dataset so it's readable by PyTables
void error(char *msg);//wrapper for perror that exits
int socket_ready(int roachno,int sockfd,int bufsz);//finds how many bytes are waiting in a roach's send buffer
int read_socket_all(int sockfd, uint32_t *pa, int bufsz);//read a packet from a roach's send buffer
int connect_to_roach(int roachno);//create a tcp connection to a roach
int write_quicklook_image(char* obs_filepath,uint16_t data[][BEAM_COLS],int sec);
void reap_child(int sig);
double current_time();
void get_obs_path(char* path, char* obs_filename, char* obs_filepath);
void setup_reap_child();
sem_t* open_h5_mutex();
void create_datasets(char* obs_filepath,char* pixel_dataset_name,int exptime);
void update_beammap_names(char* obs_filepath, const char* pixel_dataset_name, char beam_data[BEAM_ROWS][BEAM_COLS][STR_SIZE], int pixel_adr[BEAM_ROWS][BEAM_COLS]);
int get_exptime(char* obs_filepath);
void copy_beam_file_tree(char* obs_filepath,char* path,char beam_data[BEAM_ROWS][BEAM_COLS][STR_SIZE]);

void write_sec_data(char* obs_filepath,char* pixel_dataset_name,int sec[NROACHES],int ready_roach, uint64_t plist[NROACHES][NPIXELS_PER_ROACH],uint64_t*** photons,int** photon_counts, int pixel_adr[BEAM_ROWS][BEAM_COLS],int exptime);
int main(int argc, char *argv[])
{
	char path[STR_SIZE];//directory path where obs_test.h5 and beammap.h5 are
	char obs_filepath[STR_SIZE];//name of pre-existing observation file with header
	char obs_filename[STR_SIZE];//name of pre-existing observation file with header

	//IDs for reading/writing obs_test.h5
	hid_t pixel_dataset;
	hid_t pixel_dataspace;
	char pixel_dataset_name[STR_SIZE];
	char full_dataset_name[STR_SIZE];//used in renaming dataset names in obs_file/beammap/beamimage
	char dataset_name_base[STR_SIZE] = "t";
	
	int i,j,s,r = 0;
	int row = 0;
	int col = 0;
	int roach_counts[NROACHES];

	uint32_t exptime = 0;//number of seconds in the experiment, read from header
	int pixel_adr[BEAM_ROWS][BEAM_COLS];//the unique (across roaches) addresses of pixels
	time_t obs_time;//the time the observation started

	//the pixel dataset names arranged by pixel location
	char beam_data[BEAM_ROWS][BEAM_COLS][STR_SIZE];
	
	//The number of seconds with data to be put in rows for each pixel
	hsize_t N_VLrows[1];
	
	int socket_id[NROACHES];
	//which second for a roach is currently being parsed
	int sec[NROACHES];
	//this is true when all roaches have sent all second data
	int bool_all_secs_done = 0;
	//the roach currently ready to be read from
	int ready_roach = -1;
	int N_bytes = 0;
	int N_bytes_ready = 0;
	//an array of photon counts indexed by unique pixel addresses (roachno*256+pixelno)
	int** photon_counts;
	//the latest packet read from a roach buffer
    uint64_t packet;
	uint64_t old_packet[NROACHES];
	uint64_t lost_packet_check;
	int N_packets_lost = 0;
    //the pixel address of the latest packet relative to that roach, pixelno (not unique)
    int adr;
    //a table of all photons for the second currently being accumulated for each roach
    uint64_t** photons[NROACHES];//table of photons for a single second
	//uint64_t photons[NROACHES][NPIXELS_PER_ROACH][MAX_EVENTS_PER_SEC];
	//an array of photon counts for the second currently processed for each roach
    uint64_t plist[NROACHES][NPIXELS_PER_ROACH];
	
	//a buffer of lower order 32 bits read from a roach at once, to be combined with high order
	uint32_t low_order_block[BUFSIZE_INTS];
	//a buffer of higher order 32 bits from the complete 64 bit packets
	uint32_t high_order_block[BUFSIZE_INTS];

	double time_marker = 0;
	double time_between_packets = 0;
	double relative_time = 0;
	double old_current_time = 0;
	double start_time = 0;
	double current = 0;
	double time_diff = 0;
	sem_t* h5file_mutex;
	int rtrn_status = 0;
	int bool_write_quicklook = 0;
	int photon_index = 0;
	int absolute_pixel_adr = 0;

	if (argc != 2)
	{
		printf("Usage: %s OBS_FILE_PATH\n");
		return 1;
	}
	strcpy(obs_filepath,argv[1]);
	printf("obs_file_path: %s\n",obs_filepath);
	get_obs_path(path,obs_filename,obs_filepath);

	setup_reap_child();

	h5file_mutex = open_h5_mutex();
	if (errno != 0)
		error("Error opening mutex");
	exptime = get_exptime(obs_filepath);
	
	printf("exptime = %d\n",exptime);
	//Set the number of rows in each VLArray dataset for later
	N_VLrows[0] = exptime;
	obs_time = time(NULL);
	sprintf(pixel_dataset_name,"%s%d",dataset_name_base,obs_time);
	copy_beam_file_tree(obs_filepath,path,beam_data);

	create_datasets(obs_filepath,pixel_dataset_name,exptime);
	update_beammap_names(obs_filepath, pixel_dataset_name, beam_data, pixel_adr);
	photon_counts = (int**)malloc(exptime*sizeof(int*));
	if (photon_counts < 0)
		error("Allocating photon_counts failed");
	for (i = 0; i < exptime; ++i)
	{
		photon_counts[i] = (int*)malloc(NROACHES*NPIXELS_PER_ROACH*sizeof(int));
		if (photon_counts[i] < 0)
			error("Allocating photon_counts[i] failed");
		for (j = 0; j < NROACHES*NPIXELS_PER_ROACH; ++j)
		{
			photon_counts[i][j] = 0;
		}
	}
	for(r=0;r<NROACHES;++r)
	{
		socket_id[r] = connect_to_roach(r);
		printf("successfully connected to %d\n",r);
		sec[r] = 0;
		roach_counts[r] = 0;
		old_packet[r] = (uint64_t)(-1);
		photons[r] = (uint64_t **) malloc(NPIXELS_PER_ROACH*sizeof(uint64_t *));
		if(NULL == photons[r])
		{
			printf("Memory allocation failed while allocating for photons[].\n"); 
			exit(-1);
		}
		/* Allocate integer memory for the second dimension of a matrix[][]; */
		for(i = 0; i < NPIXELS_PER_ROACH; i++)
		{
			photons[r][i] = (uint64_t *) malloc(MAX_EVENTS_PER_SEC * sizeof(uint64_t));
			if(NULL == photons[r][i])
			{
				printf("Memory allocation failed while allocating for photons[x][].\n");
				exit(-1);
			}
			plist[r][i] = 0;
		}
	}
	if (errno != 0)
		error("Error before main loop");

	fflush(stdout);
	while (bool_all_secs_done == 0)
	{
		time_marker=current_time();
		ready_roach = -1;
		N_bytes = 0;
		N_bytes_ready = 0;
		for (r=0;r<NROACHES;++r)
		{
			if (sec[r] < exptime)
			{
				N_bytes = socket_ready(r,socket_id[r],BUFSIZE);
				if (N_bytes >= BUFSIZE)
				{
					//wait for the roach to start sending data to start he timer
					if (start_time == 0)
						start_time = current_time();

					if (ready_roach != -1) 
					{
						if (sec[r] < sec[ready_roach]-1 || (sec[r] <= sec[ready_roach]  && N_bytes > N_bytes_ready))
						{//If more than one roach has data, take the one that has the least seconds,
						//or if they're close to the same in that respect, take the one with the most data
							ready_roach = r;
							N_bytes_ready = N_bytes;
						}
					}
					else
					{//This is the first roach with data found
						ready_roach = r;
					}
				}
			}
		}
		if (errno != 0)
			error("Error checking for ready roaches");

		if (ready_roach != -1)
		{
			if (errno != 0)
				error("Error before reading");
			//read high order and low order bits from the roach with data ready
			read_socket_all(socket_id[ready_roach],low_order_block,BUFSIZE);
			read_socket_all(socket_id[ready_roach],high_order_block,BUFSIZE);
			if (errno != 0)
				error("Error in reading from roaches");
			
			adr = ntohl(high_order_block[0])>>24;
			packet = (((uint64_t) ntohl(high_order_block[0]))<<32) | (uint64_t) ntohl(low_order_block[0]);
			++roach_counts[ready_roach];
			current = current_time();
			time_diff = current-time_marker;

			time_between_packets = current- old_current_time;
			relative_time = current-start_time; 

			printf("packet %d %llu, pixel %d roach %d took %.3f total, %.3f to read, at %.3f %.3f\n",roach_counts[ready_roach],packet ,adr,ready_roach,time_between_packets,time_diff,relative_time,current_time);
			old_current_time = current;
	
			// extract data from packet
			for (j=0; j < BUFSIZE_INTS; j++) 
			{
				packet = (((uint64_t) ntohl(high_order_block[j]))<<32) | (uint64_t) ntohl(low_order_block[j]);
				//When the roaches are running timestamp.bof, the following can be used to check if all packets get through
				if (TIMESTAMPER == 1)
				{
					lost_packet_check = ((uint64_t)(packet & 0xfff)-(uint64_t)(old_packet[ready_roach] & 0xfff) +2501)%2501;
					if (lost_packet_check != 1 && packet != (uint64_t)(-1) && roach_counts[ready_roach] != 1)// && old_packet[ready_roach] != (uint64_t)(-1))
					{
						printf("data incremented by %d packet %d word %d old_packet %llx packet %llx\n",lost_packet_check,roach_counts[ready_roach],j,old_packet[ready_roach],packet);
						if (roach_counts[ready_roach] != 1)
							N_packets_lost += (lost_packet_check - 1)/689;
					}
				}
//				if ((roach_counts[ready_roach] == 1 || roach_counts[ready_roach] == 2) && ready_roach == 0)
//				{
//					printf("%016lx j:%d c:%d\n",packet,j,roach_counts[ready_roach]);
//				}
//				if (ready_roach == 0 && roach_counts[ready_roach] == 2 && j == 0)
//				{
//					printf("********************************************\n");
//				}
				if (packet != (uint64_t)(-1))
					old_packet[ready_roach] = packet;	
				//packet = (((uint64_t) p1[j])<<32) | (uint64_t) p0[j];

				if (sec[ready_roach] < exptime)
				{
					if (packet == (uint64_t)(-1))
					{	
						printf("second %d of %d for roach %d at %.3f \n",sec[ready_roach],exptime-1,ready_roach,current_time());
						if (errno != 0)
							error("Error before forking");

						if (fork() == 0)//create a child process to write to the H5 data file
						{
							usleep(1);
							rtrn_status = sem_wait(h5file_mutex);
							usleep(1);
							time_marker=current_time();
							write_sec_data(obs_filepath,pixel_dataset_name,sec,ready_roach,plist,photons,photon_counts,pixel_adr,exptime);

							sem_post(h5file_mutex);
							printf("time to write for sec %d for roach %d: %.3f s at %.3f\n",sec[ready_roach],ready_roach,current_time()-time_marker);
							_exit(0);//Exit the data writing child created by fork
						}
						//reset counts
						for (i=0; i < NPIXELS_PER_ROACH;++i)
						{
							plist[ready_roach][i]=0;
						}
						//increment the number of seconds processed for this roach
						sec[ready_roach] = sec[ready_roach] + 1;
						if (sec[ready_roach] == exptime)
							close(socket_id[ready_roach]);

						fflush(stdout);
						
					}
					else
					{
						adr = ntohl(high_order_block[j])>>24;
						//add photon to table, increment photon counts
						//the old number of photons for this pixel plist[ready_roach][adr]
						//is the index where this photon must go
						photon_index = plist[ready_roach][adr];
						photons[ready_roach][adr][photon_index] = packet;
						if (plist[ready_roach][adr] < (MAX_EVENTS_PER_SEC - 1))
						{
							++plist[ready_roach][adr];
							absolute_pixel_adr = ready_roach*NPIXELS_PER_ROACH+adr;
							++photon_counts[sec[ready_roach]][absolute_pixel_adr];
						}
					}
				}
	
			}
			
		}
		bool_all_secs_done = 1;//initialize to true and falsify with && if not
		for (r=0;r<NROACHES;++r)
		{//check if all roach's seconds elapsed has passed exptime
			bool_all_secs_done = bool_all_secs_done && (sec[r] >= exptime);
		}
	}
	for (i = 0; i < exptime; ++i)
	{
		printf("counts for sec %d: ",i);
		//print the number of photons per sec of the tenth(picked arbitrarily) pixel of each roach
		for (j = 10; j < NROACHES*NPIXELS_PER_ROACH; j+=NPIXELS_PER_ROACH)
		{
			printf("%d ",photon_counts[i][j]);
		}
		printf("\n");
	}
	free(photon_counts);
	for (r=0; r<NROACHES; ++r)
	{
		for(i = 0; i < NPIXELS_PER_ROACH; i++)
		{
			free(photons[r][i]);
		}
	}
	for (r=0; r<NROACHES; ++r)
	{
		free(photons[r]);
		//close(socket_id[r]);
	}
    
	//printf("Lost count: %d\n",N_packets_lost);
	return 0;
}



void append_path(const char* path, char* rest)
{
	char str_temp[STR_SIZE];
	sprintf(str_temp,"%s%s",path,rest);
	strcpy(rest,str_temp);
}

void add_group_attrs(hid_t group)
{
	herr_t	status;

	hid_t attr_group_class, attr_group_title, attr_group_version;
	hid_t attrs_space, attrs_type;
	
	char str_group_class[STR_SIZE] = "GROUP";
	char str_group_title[STR_SIZE] = "";
	char str_group_version[STR_SIZE] = "1.0";
				//set up the type and size for C-string attributes

	attrs_type = H5Tcopy (H5T_C_S1);
	status = H5Tset_size (attrs_type, STR_SIZE);
	attrs_space = H5Screate (H5S_SCALAR);	

	//Create VLARRAY  file attribute tags to attach to the root group
	attr_group_class = H5Acreate (group, "CLASS", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
	attr_group_title = H5Acreate (group, "TITLE", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
	attr_group_version = H5Acreate (group, "VERSION", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
		 
	status = H5Awrite(attr_group_class, attrs_type, str_group_class);
	status = H5Aclose(attr_group_class);
	
	status = H5Awrite(attr_group_title, attrs_type, str_group_title);
	status = H5Aclose(attr_group_title);
	
	status = H5Awrite(attr_group_version, attrs_type, str_group_version);
	status = H5Aclose(attr_group_version);
	status = H5Sclose(attrs_space);
	status = H5Tclose(attrs_type);
}

void add_dataset_attrs(hid_t dataset)
{
	herr_t	status;

	hid_t attr_data_class, attr_data_title, attr_data_version;
	hid_t attrs_space, attrs_type;
	char str_data_class[STR_SIZE] = "VLARRAY";
	char str_data_title[STR_SIZE] = "data for one pixel at one sec";
	char str_data_version[STR_SIZE] = "1.3";
				//set up the type and size for C-string attributes

	attrs_type = H5Tcopy (H5T_C_S1);
	status = H5Tset_size (attrs_type, STR_SIZE);
	attrs_space = H5Screate (H5S_SCALAR);
		//Create VLARRAY attribute tags to attach to the dataset
	attr_data_class = H5Acreate (dataset, "CLASS", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
	status = H5Awrite(attr_data_class, attrs_type, str_data_class);
	status = H5Aclose(attr_data_class);
	attr_data_title = H5Acreate (dataset, "TITLE", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
	status = H5Awrite(attr_data_title, attrs_type, str_data_title);
	status = H5Aclose(attr_data_title);
	attr_data_version = H5Acreate (dataset, "VERSION", attrs_type, attrs_space, 
		 H5P_DEFAULT, H5P_DEFAULT);
	status = H5Awrite(attr_data_version, attrs_type, str_data_version);
	status = H5Aclose(attr_data_version);
	
	status = H5Sclose(attrs_space);
	status = H5Tclose(attrs_type);
}

/* 
 * error - wrapper for perror
 */
void error(char *msg) 
{
	printf("%s\n",msg);
    perror(msg);
    exit(1);
}

int socket_ready(int roachno,int sockfd,int bufsz)
{
	char tmp[128*bufsz];
	int N_bytes_ready = recv(sockfd, tmp, 128*bufsz, MSG_PEEK | MSG_DONTWAIT);
	double N_buffers_ready = 0;
	if (N_bytes_ready < 0 && errno != EAGAIN)
			error("Error receiving");
	if (errno == EAGAIN)//There was no data to receive, we'll reset errno and try again later
		errno = 0;
	if (N_bytes_ready == -1)
		N_bytes_ready = 0;
	N_buffers_ready = ((double)N_bytes_ready)/(2*(double)bufsz); 
	if (N_buffers_ready > 4.0 && N_buffers_ready < 65)
		printf("%.3f buffers ready for roach %d\n",N_buffers_ready,roachno);
	if (N_buffers_ready > 60)
		fprintf(stderr,"Warning! Server buffers are filling faster than emptied. Could be losing packets!\n");
	if (errno != 0)
		error("Error checking for ready socket");
	return N_bytes_ready;	
}

int read_socket_all(int sockfd, uint32_t *pa, int bufsz)
{
    // alternate version of readall that waits until buffer has bufsz bytes in it before reading
    int n;
    char tmp[bufsz];
    int usec = 1000; // length of time to sleep, in microseconds
    struct timespec req = {0};
    req.tv_sec = 0;
    req.tv_nsec = usec * 1000L;

    while (1) {
        bzero(tmp, bufsz);
        n = recv(sockfd, tmp, bufsz, MSG_PEEK);
        if (n < 0)
			error("Error receiving");
        else if ( n < bufsz ) {
            nanosleep(&req, (struct timespec *)NULL);  
            continue;
        } 
        if ( n >= bufsz) {
            break;
        }
    }
    
    //bzero(buf, bufsz);
    //n = recv(sockfd, buf, bufsz, 0);
    bzero(tmp, bufsz);
    n = read(sockfd, tmp, bufsz);        
    bcopy(tmp,pa,bufsz);
    return(n);
}

int connect_to_roach(int roachno)
{
    int sockfd,socket_flags;
    struct sockaddr_in serveraddr;
    struct hostent *server;
    long rcvbufsize;
    struct timeval tv;
    int usec = 1000; // length of time to sleep, in microseconds
    struct timespec req = {0};
    int portno = 50000;// + roachno;//$$ Change port number for roaches
    req.tv_sec = 0;
    req.tv_nsec = usec * 1000L;
    char* hostnames[] = {"10.0.0.10","10.0.0.11","10.0.0.12","10.0.0.13"};
    //char* hostnames[] = {"127.0.0.1"};//$$ Change hostnames
    /* socket: create the socket */
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) 
		error("ERROR opening socket");
    
    // set up massive receive buffer
    //rcvbufsize = 33554432;
    rcvbufsize = 32*64*2*BUFSIZE;
    if (setsockopt(sockfd,SOL_SOCKET,SO_RCVBUF,&rcvbufsize,sizeof(rcvbufsize)) == -1) 
		error("setsockopt:RCVBUF");

    /* gethostbyname: get the server's DNS entry */
    server = gethostbyname(hostnames[roachno]);//[0]//for local simulation
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host as %s\n", hostnames[roachno]);//$$[0] for local simulation
        //exit(0);
    }

    /* build the server's Internet address */
    bzero((char *) &serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serveraddr.sin_addr.s_addr, server->h_length);
    serveraddr.sin_port = htons(portno);

    /* connect: create a connection with the server */
    if (connect(sockfd, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) < 0) 
        error("ERROR connecting");
        
	//socket_flags=fcntl(sockfd,F_GETFL,0);              // Get socket flags
	//fcntl(sockfd,F_SETFL,socket_flags | O_NONBLOCK);   // Add non-blocking flag
    //seconds = time(NULL);
    //gettimeofday(&tv, NULL); 
    //printf("Waiting for data at : %ld.%ld\n",tv.tv_sec,tv.tv_usec);
    return sockfd;
}

int write_quicklook_image(char* obs_filepath, uint16_t data[BEAM_ROWS][BEAM_COLS],int sec)
{
	char bin_path[STR_SIZE] = "bin/";
	char obs_filename_root[STR_SIZE];
	char obs_filename[STR_SIZE];
	char npy_filename[STR_SIZE];
	char obs_path[STR_SIZE];
	char lock_filename[STR_SIZE];
	char header[] = "\x93NUMPY\x01\x00\x46\x00{'descr': '<i2', 'fortran_order': False, 'shape': (32, 32), }        \n";
	FILE* fid;
	FILE* lock_fid;
	const int N_bytes = 2128;
	int i = 0;
	int j = 0;
	int success = 0;
	get_obs_path(obs_path,obs_filename,obs_filepath);
	sscanf(obs_filename,"%[^.].h5",obs_filename_root);
	sprintf(npy_filename,"%s_%d.npy",obs_filename_root,sec);
	sprintf(lock_filename,"lock.%d",sec);
	append_path(obs_path,bin_path);
	append_path(bin_path, npy_filename);
	append_path(bin_path, lock_filename);
	fid  = fopen(npy_filename,"wb");
	lock_fid  = fopen(lock_filename,"w");
	fclose(lock_fid);
	if (fid <= 0)
	{
		success = mkdir(bin_path,0755);
		fid = fopen(npy_filename,"wb");
		lock_fid  = fopen(lock_filename,"w");
		fclose(lock_fid);
		if (fid <= 0 || success != 0)
			error("Error creating npy file");
		
	}
	fseek(fid,0,SEEK_SET);
	fwrite(header,sizeof(char),5*16,fid);
	for(i = 0; i < BEAM_ROWS; ++i)
	{
		for (j = 0; j < BEAM_COLS; ++j)
		{
			fwrite(&data[i][j],sizeof(uint16_t),1,fid);
			//printf("%02d ",data[i][j]);
		}
		//printf("\n");
	}
	fclose(fid);
	remove(lock_filename);
	return 0;
}

void reap_child(int sig)
{
	int status;
	pid_t pid;
	signal(SIGCHLD,reap_child); //reset handler to catch SIGCHLD for next time;

	pid = wait(&status); //After wait, child is definitely freed.
	if (status != 0)
	{
		printf("Data writing child process ended in error %d\n",status);
	}
}

double current_time()
{
	struct timeval tv;
	gettimeofday(&tv,NULL);
	return tv.tv_sec+tv.tv_usec*1e-6;
}

void get_obs_path(char* path, char* obs_filename, char* obs_filepath)
{
	char temp[STR_SIZE];
	int len = strlen(obs_filepath);
	int i = 0;
	int last_slash_index = 0;
	int N_chars_before_filename = 0;
	strcpy(path,"");
	for (i = 0; i < len;  ++i)
	{
		if (obs_filepath[i] == '/')
		last_slash_index = i;
	}
	N_chars_before_filename = last_slash_index+1;
	if (N_chars_before_filename == 1 && path[0] != '/')
		N_chars_before_filename = 0;
	strncpy(path,obs_filepath,N_chars_before_filename);
	strcpy(obs_filename,obs_filepath+N_chars_before_filename);
	path[N_chars_before_filename]='\0';
}

void setup_reap_child()
{
	struct sigaction sa;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = 0;
	sa.sa_handler = reap_child;
	signal(SIGCHLD, SIG_IGN);
	//sigaction(SIGCHLD, &sa, NULL);
}

sem_t* open_h5_mutex()
{
	sem_t* h5file_mutex;
	if ((h5file_mutex = sem_open("h5file_mutex", O_CREAT | O_EXCL, 0644, 1)) == SEM_FAILED) 
	{
		errno = 0;
		sem_unlink("h5file_mutex");
		h5file_mutex = sem_open("h5file_mutex", O_CREAT | O_EXCL, 0644, 1);
		if (errno != 0)
			error("semaphore initialization");
	}
	return h5file_mutex;
}

void copy_beam_file_tree(char* obs_filepath,char* path,char beam_data[BEAM_ROWS][BEAM_COLS][STR_SIZE])
{
	//the beammap indicates which roach pixels correspond to the pixel coordinates

	hid_t obs_file;//The file handle for the H5 file containing initial header data and will contain all observation data
	//items used for reading header info.  The header is itself one record of a complex H5 type
	//so when reading...
	hsize_t read_start = 0; //start with the first and only record
	hsize_t read_nrecords = 1;//and read data from exactly one record
	size_t beam_str_type_size = STR_SIZE*sizeof(char);
	size_t read_offset[] = {0};
	size_t beam_sizes[] = {STR_SIZE*sizeof(char)};
	char beammap_filename[STR_SIZE];//h5 file name read from obs_test.h5 header
	int i;
	//IDs for reading h5 file
	hid_t beam_dataset;
	hid_t beam_data_type;
	hid_t beam_group;
	hid_t beammap_file;//An H5 file that indicates how pixel position maps to channel number
	hid_t obs_root;//The root group in obs_file
	herr_t	status;//The return status of H5 functions, -1 indicates an error
	obs_file = H5Fopen(obs_filepath, H5F_ACC_RDWR, H5P_DEFAULT);
	if (obs_file < 0)
	{
		fprintf(stderr,"Error opening obs file %s",obs_filepath);
		error("");
	}
	//read the beammap filename from obs_file, open it, and copy its contents to obs_file
	status = H5TBread_fields_name(obs_file,"/header/header","beammapfile",read_start,read_nrecords,beam_str_type_size,read_offset,beam_sizes,beammap_filename);
	if (status < 0)
		error("Error reading beammap filename from header");
	printf("beammap file: %s\n",beammap_filename);
	printf("beammap path: %s\n",path);
	append_path(path,beammap_filename);
	printf("beammap file: %s\n",beammap_filename);

	beammap_file = H5Fopen(beammap_filename,H5F_ACC_RDWR, H5P_DEFAULT);
	if (beammap_file < 0)
	{
		fprintf(stderr,"Error opening beammap file %s : ",beammap_filename);
		error("");
	}
	beam_dataset = H5Dopen(beammap_file,"/beammap/beamimage",H5P_DEFAULT);
	beam_data_type = H5Tcopy (H5T_C_S1);
	status = H5Tset_size (beam_data_type, STR_SIZE);
	status = H5Dread(beam_dataset,beam_data_type,H5S_ALL,H5S_ALL,H5P_DEFAULT,beam_data);
	status = H5Tclose(beam_data_type);
	if (status < 0)
		error("Error reading beammap dataset");
	beam_group = H5Gopen(beammap_file,"/",H5P_DEFAULT);
	obs_root = H5Gopen(obs_file,"/",H5P_DEFAULT);
	status = H5Ocopy(beam_group,"beammap",obs_root,"beammap",H5P_DEFAULT,H5P_DEFAULT);
	if (status < 0)
		error("Error copying beammap tree to obs file");
	status = H5Dclose(beam_dataset);
	status = H5Gclose(obs_root);
	status = H5Fclose(beammap_file);
	status = H5Gclose(beam_group);
	status = H5Fclose(obs_file);
}

int get_exptime(char* obs_filepath)
{
	hid_t obs_file;//The file handle for the H5 file containing initial header data and will contain all observation data
	//get the number of seconds in the experiment from the header file

	//items used for reading header info.  The header is itself one record of a complex H5 type
	//so when reading...
	hsize_t read_start = 0; //start with the first and only record
	hsize_t read_nrecords = 1;//and read data from exactly one record
	size_t read_offset[] = {0};
	size_t exptime_sizes[] = {sizeof(uint32_t)};//used to read exptime from header
	herr_t	status;//The return status of H5 functions, -1 indicates an error
	int exptime = 0;
	obs_file = H5Fopen(obs_filepath, H5F_ACC_RDWR, H5P_DEFAULT);
	if (obs_file < 0)
	{
		fprintf(stderr,"Error opening obs file %s",obs_filepath);
		error("");
	}
	status = H5TBread_fields_name(obs_file,"/header/header","exptime",read_start,read_nrecords,sizeof(uint32_t),read_offset,exptime_sizes,&exptime);
	if (exptime == 0 || status < 0)
		error("Error retrieving exptime from obs file header");
	status = H5Fclose(obs_file);
	return exptime;

}

void update_beammap_names(char* obs_filepath, const char* pixel_dataset_name, char beam_data[BEAM_ROWS][BEAM_COLS][STR_SIZE], int pixel_adr[BEAM_ROWS][BEAM_COLS])
{
	char full_dataset_name[STR_SIZE];//used in renaming dataset names in obs_file/beammap/beamimage
	//used with strtok to put beammap data in obs_file
	char* roach_name;
	char* pixel_name;
	int i,j;
	hid_t obs_file;//The file handle for the H5 file containing initial header data and will contain all observation data
	hid_t beam_dataset;
	hid_t beam_data_type;
	herr_t	status;//The return status of H5 functions, -1 indicates an error
	obs_file = H5Fopen(obs_filepath, H5F_ACC_RDWR, H5P_DEFAULT);
	//datasets are set up in a hierarchy of the form /r#/p#/t#
	for(i=0;i<BEAM_ROWS;++i)
	{
		for(j=0;j<BEAM_COLS;++j)
		{
			strcpy(full_dataset_name,beam_data[i][j]);
			roach_name = strtok(beam_data[i][j],"/");
			pixel_name = strtok(NULL,"/");
			//increment string pointers past 'r' or 'p' char and convert to int
			pixel_adr[i][j] = atoi(roach_name+1)*NPIXELS_PER_ROACH+atoi(pixel_name+1);
			strcat(full_dataset_name,pixel_dataset_name);
			strcpy(beam_data[i][j],full_dataset_name);			
		}
	}
	beam_dataset = H5Dopen(obs_file,"/beammap/beamimage",H5P_DEFAULT);
	if (beam_dataset < 0)
		error("Error opening beam_dataset");

	beam_data_type = H5Tcopy (H5T_C_S1);
	status = H5Dwrite(beam_dataset,beam_data_type,H5S_ALL,H5S_ALL,H5P_DEFAULT,beam_data);
	if (status < 0)
		error("Error updating beammap dataset in obs_file");
	status = H5Tclose(beam_data_type);
	status = H5Dclose(beam_dataset);
	status = H5Fclose(obs_file);
	return;
}

void create_datasets(char* obs_filepath,char* pixel_dataset_name,int exptime)
{
	hid_t pixel_dataspace;
	hid_t pixel_group;
	hid_t roach_group;
	hid_t pixel_dataset;
	hid_t pixel_datatype;
	hid_t obs_root;//The root group in obs_file
	hid_t obs_file;
	herr_t	status;//The return status of H5 functions, -1 indicates an error
	hsize_t N_VLrows[1];
	int i,j;
	char roach_group_name[STR_SIZE];
	char pixel_group_name[STR_SIZE];
	char roach_group_name_base[STR_SIZE] = "r";
	char pixel_group_name_base[STR_SIZE] = "p";
	N_VLrows[0] = exptime;
	obs_file = H5Fopen(obs_filepath, H5F_ACC_RDWR, H5P_DEFAULT);

	//Create a dataspace (size information object) for the data to be written
	//The data will have 1 dimension of variable length rows, so rank=1
	//array of dimension sizes has one element, row_size=exptime
	//This is not extendable, so maxsize=NULL
	pixel_dataspace = H5Screate_simple(DATA_RANK, N_VLrows, NULL);
	//Create a vlarray datatype that describes the data in the dataset
	pixel_datatype = H5Tvlen_create(H5T_NATIVE_ULONG); 
	
	//Now create the group hierarchy in obs file
	//A dataset could be /r1/p2/t1378901 where 1 is the roach number, 2 is the channel number
	//datasets are named t# where # is the observation time
	obs_root = H5Gopen(obs_file,"/",H5P_DEFAULT);
	for(i=0;i<NROACHES;++i)
	{
		sprintf(roach_group_name,"%s%d",roach_group_name_base,i);
		roach_group = H5Gcreate(obs_root,roach_group_name, H5P_DEFAULT,H5P_DEFAULT,H5P_DEFAULT);
		add_group_attrs(roach_group);//make each group readable by pytables

		for(j = 0;j < NPIXELS_PER_ROACH;++j)
		{
			sprintf(pixel_group_name,"%s%d",pixel_group_name_base,j);
			pixel_group = H5Gcreate(roach_group, pixel_group_name,H5P_DEFAULT,H5P_DEFAULT,H5P_DEFAULT);
			add_group_attrs(pixel_group);
			pixel_dataset = H5Dcreate(pixel_group, pixel_dataset_name, pixel_datatype, pixel_dataspace, H5P_DEFAULT,H5P_DEFAULT,H5P_DEFAULT);
			add_dataset_attrs(pixel_dataset);
			status = H5Dclose(pixel_dataset);
			status = H5Gclose(pixel_group);
		}

		status = H5Gclose(roach_group);
	}
	status = H5Tclose(pixel_datatype);
	status = H5Sclose(pixel_dataspace);
	status = H5Gclose(obs_root);
	status = H5Fclose(obs_file);
	return;
}

void write_sec_data(char* obs_filepath,char* pixel_dataset_name,int sec[NROACHES],int ready_roach, uint64_t plist[NROACHES][NPIXELS_PER_ROACH],uint64_t*** photons,int** photon_counts, int pixel_adr[BEAM_ROWS][BEAM_COLS],int exptime)
{
	hid_t obs_file;
	hid_t pixel_dataspace;
	hid_t pixel_dataset;
	hid_t pixel_datatype;
	int i,j,r,row,col;
	int channel;
	herr_t status;
	int bool_write_quicklook;
	char full_dataset_name[STR_SIZE];//used in renaming dataset names in obs_file/beammap/beamimage
	int current_sec = sec[ready_roach];
	uint16_t quicklook_image[BEAM_ROWS][BEAM_COLS];//32x32 image made by number of counts for each pixel
	hsize_t N_VLrows[1];
	N_VLrows[0] = exptime;
	//the VL photon array to be added as one second's data for a single pixel
	hvl_t new_sec_row;
	//the dimensions of new_sec_row (1D array containing one element - a VL array)
	hsize_t dims_new[1] = {1};
	//which row of a pixel's dataset where new_sec_row should be added
	hsize_t start[1] = {0};

	obs_file = H5Fopen(obs_filepath, H5F_ACC_RDWR, H5P_DEFAULT);
	pixel_datatype = H5Tvlen_create(H5T_NATIVE_ULONG); 

	//the memory space selecting all of new_sec_row to be added into a dataset
	hid_t mem_space = H5Screate_simple(DATA_RANK, dims_new, NULL);
	//set up dataspaces so that one row can be inserted to a dataset
	pixel_dataspace = H5Screate_simple(DATA_RANK, N_VLrows, NULL);
	start[0] = current_sec;
	status = H5Sselect_hyperslab(pixel_dataspace, H5S_SELECT_SET, start, NULL, dims_new, NULL);
	if (status != 0)
		error("ERROR in H5 select");

	for (i=0; i < NPIXELS_PER_ROACH;++i)
	{
		sprintf(full_dataset_name,"/r%d/p%d/%s",ready_roach,i,pixel_dataset_name);
		pixel_dataset = H5Dopen(obs_file,full_dataset_name,H5P_DEFAULT);
		//append current ready_roach row to VLArray
		new_sec_row.len = plist[ready_roach][i];
		new_sec_row.p = photons[ready_roach][i];
		status = H5Dwrite(pixel_dataset,pixel_datatype,mem_space,pixel_dataspace,H5P_DEFAULT,&(new_sec_row));
		if (status < 0)
			error("Error during sec data write");
		status = H5Dclose(pixel_dataset);
	}
	status = H5Sclose(mem_space);
	status = H5Sclose(pixel_dataspace);
	status = H5Tclose(pixel_datatype);
	status = H5Fclose(obs_file);
	bool_write_quicklook = 1;
	for (r = 0; r < NROACHES; ++r)
	{
		if (r != ready_roach)
			bool_write_quicklook = bool_write_quicklook && (sec[r] >= current_sec + 1);
	}
	if (bool_write_quicklook == 1)
	{
		for (row=0; row < BEAM_ROWS;++row)
		{
			for (col = 0; col < BEAM_COLS;++col)
			{
				channel = pixel_adr[row][col];
				quicklook_image[row][col] = photon_counts[current_sec][channel];
			}
		}
		write_quicklook_image(obs_filepath,quicklook_image,current_sec);
	}
	if (status != 0)
	{
		error("ERROR in H5 write");
	}
}
