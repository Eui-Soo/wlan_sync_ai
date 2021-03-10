function output = complex_awgn_gen(No,len)

% Generate complex AWGN
NI=sqrt(No/2)*randn(len,1);
NQ=sqrt(No/2)*randn(len,1);
output = NI+1i*NQ;      

end

