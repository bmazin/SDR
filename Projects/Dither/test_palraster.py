import TCS
import time
s = TCS.TCS()
time.sleep(1)
s.raster(step=6,numX=6,numY=6,integrateTime=60)
