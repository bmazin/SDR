copy implementation\system.bit ..\bit_files\chan_512_packet_2012_Jul_19_2144.bit
mkbof.exe -o implementation\system.bof -s core_info.tab -t 3 implementation\system.bin
copy implementation\system.bof ..\bit_files\chan_512_packet_2012_Jul_19_2144.bof
