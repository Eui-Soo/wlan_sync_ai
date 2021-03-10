function y = cp_insert(x,fft_pt)

num_cp = 16;

L=length(x);
y = zeros(1,(fft_pt+num_cp)*L/fft_pt);

for n= 1: L/fft_pt
    temp = x(fft_pt*(n-1)+1 : fft_pt*n);  
    y((fft_pt+num_cp)*(n-1)+1:(fft_pt+num_cp)*n)=[temp(end-num_cp+1:end) temp];
end