import shard
import time
s = shard.Shard()

time.sleep(2)
s.move(1,0)
time.sleep(2)
s.move(-1,0)

