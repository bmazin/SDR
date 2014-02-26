def lpf(x, tau, dt):
	L = len(x)
	alpha = dt/(tau+dt)
	y = [0]*L
	y[0] = alpha*x[0]
	for i in range(1,L):
		y[i] = alpha*x[i] + (1 - alpha)*y[i-1]

	return y

def opt_filter_iir(x, tau, omega, dt):
	L = len(x)
	y = [0.]*L
	d = 1 + tau/dt + 1/(omega**2*dt**2)
	a1 = (tau/dt+2/(omega**2*dt**2))/d
	a2 = -1/omega**2/dt**2/d
	b0 = tau/dt/d
	b1 = -tau/dt/d
	for i in range(2,L):
		y[i] = a1*y[i-1] + a2*y[i-2] + b0*x[i] + b1*x[i-1]

	return y
