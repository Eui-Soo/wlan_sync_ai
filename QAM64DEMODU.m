function demap_bits=QAM64DEMODU(data)
demap_bits=zeros(length(data),6);
demap_bits(:,1)=(real(data).*sqrt(42))>0;
demap_bits(:,2)=(abs(real(data)).*sqrt(42))<4;
demap_bits(:,3)=(abs(real(data).*sqrt(42))>2)&(abs(real(data).*sqrt(42))<6);
demap_bits(:,4)=(imag(data).*sqrt(42))>0;
demap_bits(:,5)=(abs(imag(data)).*sqrt(42))<4;
demap_bits(:,6)=(abs(imag(data).*sqrt(42))>2)&(abs(imag(data).*sqrt(42))<6);