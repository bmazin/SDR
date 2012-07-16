import corr, time, sys

ip = str(sys.argv[1])
bof = str(sys.argv[2])

print "opening client and programming "+ip+"..."
roach = corr.katcp_wrapper.FpgaClient(ip, 7147)
time.sleep(1)

print "and programming "
roach.progdev(bof)
time.sleep(1.5)
print "done"


