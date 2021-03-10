function demap_bits=QPSKDEMODU(data)
demap_bits=zeros(length(data),2);
demap_bits(:,1)=(real(data).*sqrt(2))>0;
demap_bits(:,2)=(imag(data).*sqrt(2))>0;