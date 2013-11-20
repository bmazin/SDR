import shard
s = shard.Shard()
#s.connect()

time.sleep(1)
s.move(1,0)
time.sleep(1)
s.move(-1,0)

