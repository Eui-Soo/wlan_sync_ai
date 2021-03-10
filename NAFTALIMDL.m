function [imp,out,Tow,sigmak_sqr,Pn] = NAFTALIMDL(INPT_SIG,OUT_RATE,Trms)

format long g;
Ts = 1/(4*OUT_RATE);
KMAX = 10*Trms/Ts;
sigmao_sqr = 1-exp(-Ts/Trms);

ii = 0:1:round(KMAX);
Pn = sqrt(exp((-ii*Ts)/Trms));
Pndb = 10*log10(exp((-ii*Ts)/Trms));
sigmak_sqr = (sigmao_sqr)*exp((-ii*Ts)/Trms);
Gn = normrnd(0,0.5*sigmak_sqr) + i*normrnd(0,0.5*sigmak_sqr);
Tow = ii*Ts;
imp = Pn.*Gn;
out = conv(INPT_SIG,imp);

