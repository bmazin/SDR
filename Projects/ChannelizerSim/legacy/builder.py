

def recursive(N, M):
	for i in range(N):
		s = 'y'+str(i)+' = '
		for j in range(M):
			s = s + '  ' + str(j) + str(j+i)
		print s	


def recursive2(N=4, M=1):
	


#recursive(4, 3)

M= 2
a = ['a'+str(i) for i in range(M)]
