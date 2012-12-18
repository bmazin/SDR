#!/bin/python
import subprocess

class Shard:
    def move(self,ra,dec):
        commandTemplate = 'TELMOVE INSTRUMENT %.2f %.2f SEC_ARC NOWAIT\n'
        command  = commandTemplate%(ra,dec)
        print command
        self.session.stdin.write(command)

    def connect(self):
        hostname = 'shard.ucolick.org'
        port = 2345
        self.session = subprocess.Popen('telnet %s %d'%(hostname,port),shell=True,stdin=subprocess.PIPE)
        print 'Connected'
    def close(self):
        print 'Closing Telnet session'
        #self.session.close()

    def __init__(self):
        self.connect()
    def __del__(self):
        self.close()


    

