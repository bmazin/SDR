#!/bin/python
import telnetlib

class Shard:
    def move(self,ra,dec):
        commandTemplate = 'TELMOVE INSTURMENT %.2f %.2f SEC_ARC NOWAIT\n'
        command  = commandTemplate%(ra,dec)
        print command
        self.session.write(command)
        print self.session.read_lazy()
    def connect(self):
        hostname = 'shard.ucolick.org'
        port = 2345
        self.session = telnetlib.Telnet()
        self.session.open(hostname,port)
    def close(self):
        print 'Closing Telnet session'
        self.session.close()

    def __init__(self):
        self.connect()
    def __del__(self):
        self.close()


    

