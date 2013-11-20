PRO ResEstimates,datapath,outpath,pulsename,StartT,atten,res,pm,life,phr,loss

; pulse height for center of strip event in radians
ph = phr[2]*!Pi/180.0
ph2 = phr[3]*!Pi/180.0

path = outpath

; load templates and noise spectra
dat = read_ascii(path+'Template-2pass.dat')
dat = dat.field1 
idx = (dat[0,*])[*]
t1 = (dat[1,*])[*]
t2 = (dat[2,*])[*]

dat = read_ascii(path+'NoiseSpectra-2pass.dat')
dat = dat.field1 
Fa = (dat[0,0:799])[*]
n1 = (dat[1,0:799])[*]
n2 = (dat[2,0:799])[*]

fitdata = path+'Series-ps.dat'
fitdat = read_ascii(fitdata)
fitdat = fitdat.field01

; mess around with lowest FFT bin
n1[0] = 2.0*n1[1]
n1[799] = 2.0*n1[798]

n2[0] = 2.0*n2[1]
n2[799] = 2.0*n2[798]

ch1nc = n1
ch2nc = n2

; rebin noise
N = 800 
T = 1.25d-6
N21 = N/2 + 1 
F = INDGEN(N) 
F[N21] = N21 -N + FINDGEN(N21-2) 
F = (F/(N*T))[0:399] 

;construct optimal filters
opt1 = FFT(t1[900:1699],-1)
;opt1 = FFT((hanning(2000)*t1)[900:1699],-1)

opt2 = FFT(t2[900:1699],-1)
;opt2 = FFT((hanning(2000)*t2)[900:1699],-1)

phi1=conj(opt1)/ch1nc
phi2=conj(opt2)/ch2nc

optnorm1c = total( abs(opt1)^2/ch1nc)
optnorm2c = total( abs(opt2)^2/ch2nc)

optns1 = sqrt( 1.0/(1000.0d-6*total(abs(opt1)^2/ch1nc)))
optns2 = sqrt( 1.0/(1000.0d-6*total(abs(opt2)^2/ch2nc)))

;Do we get ph out from the estimator?  Yes 
;Ahat = total( conj(opt1)*FFT(ph*t1[900:1700],-1)/ch1nc)/total( abs(opt1)^2/ch1nc  )

print,'Opt. Flt. S/N',ph/optns1,ph2/optns2
print,'Opt. Flt. R',ph/(optns1*2.355),ph2/(optns2*2.355)
;print,'Opt. Flt. dE',5900.0/(sqrt((ph/optns1)^2 + (ph/optns2)^2)/2.355),' eV'

; put on Jiansong's noise plot
; calculate internal power
dipdb1 = fitdat[7,0]
dipdb2 = fitdat[7,1]

dip1 = 10.0^(dipdb1/20.0)
dip2 = 10.0^(dipdb2/20.0)

Q1 = fitdat[3,0]
f0 = fitdat[5,0]

Q2 = fitdat[3,1]

Qc1 = Q1*(1.0/(1.0/dip1 + 1.0) + 1.0)
Qc2 = Q2*(1.0/(1.0/dip2 + 1.0) + 1.0)

Qi1 = Qc1*(1.0/dip1 - 1.0)
Qi2 = Qc2*(1.0/dip2 - 1.0)

pow = 10.0^((-atten-loss)/10.0)

P1 = 10.0*alog10(2.0 * Q1^2/(!Pi * Qc1)*pow)
P2 = 10.0*alog10(2.0 * Q2^2/(!Pi * Qc2)*pow)

; now calculate noise at 1 kHz
;fn1 = (ch1nc[4]*(fitdat[5,0]/(4.0*Q1))^2)/(fitdat[5,0]^2)
;fn2 = (ch2nc[4]*(fitdat[5,1]/(4.0*Q2))^2)/(fitdat[5,1]^2)
fn1 = ch1nc[1]/(16.0*Q1^2)
fn2 = ch2nc[1]/(16.0*Q2^2)

curdens = sqrt(2.0*(2.0*!Pi*f0)*0.01466d-12*pow*Q1)/2.0d-6
print,'Current Density',curdens

print,'Pint',P1,P2
print,'FN @ 1 kHz',fn1,fn2

openw,2,outpath+'ResEstimates.txt'
printf,2,'Pulse Height',phr[0],phr[1]
printf,2,'Opt. Flt. S/N',ph/optns1,ph2/optns2
printf,2,'Opt. Flt. R ',ph/(optns1*2.355),ph2/(optns2*2.355)
printf,2,'Dips        ',dip1,dip2
printf,2,'Qm          ',Q1,Q2
printf,2,'Qc          ',Qc1,Qc2
printf,2,'Qi          ',Qi1,Qi2
printf,2,'Pint        ',P1,P2
printf,2,'PN @ 1 kHz  ',ch1nc[4],ch2nc[4]
printf,2,'FN @ 1 kHz  ',fn1,fn2
close,2

cmd = strcompress('enscript -p ' + outpath+'ResEstimates.ps '+outpath+ 'ResEstimates.txt')
SPAWN,cmd

end