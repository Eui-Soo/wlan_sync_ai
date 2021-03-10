function demap_bits=QAM16DEMODU(data)
demap_bits=zeros(length(data),4);
demap_bits(:,1)=(real(data).*sqrt(10))>0;
demap_bits(:,2)=(abs(real(data)).*sqrt(10))<2;
demap_bits(:,3)=(imag(data).*sqrt(10))>0;
demap_bits(:,4)=(abs(imag(data)).*sqrt(10))<2;