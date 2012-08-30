import collections
indexofpickedapproxf=[1,2,3,3,4,5,6,7,7]
approxfPicked2x=[x for x, y in collections.Counter(indexofpickedapproxf).items() if y > 1]
print approxfPicked2x
