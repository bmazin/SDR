sysgen_startup
addpath('/home/sean/bwrc/xps_library');
addpath('/home/sean/bwrc/casper_library');
addpath('/home/sean/bwrc/gavrt_library');
system_dependent('RemoteCWDPolicy','reload')
system_dependent('RemotePathPolicy','reload')
load_system('casper_library');
