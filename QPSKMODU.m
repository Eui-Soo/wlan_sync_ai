function Symbols = QPSKMODU(bits_v)
bits_i=bits_v(1:2:end);
bits_q=bits_v(2:2:end);
L=length(bits_v)/2;
Symbols=zeros(1,L);
for n=1:L
    Symbols(n)=((bits_i(n)*(2)-1)+1i*(bits_q(n)*(2)-1))*sqrt(1/2);
end
