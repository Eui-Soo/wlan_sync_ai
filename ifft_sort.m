function y = ifft_sort(x,N_fft)
frame = length(x)/52;   % unit of data+pilot = 52
y = zeros(1,frame*N_fft);

for n=1:frame
   temp = x(52*(n-1) +1 : 52*n); 
   y(N_fft*(n-1)+1:N_fft*n) = [0 temp(27:52) zeros(1,11) temp(1:26)]; 
end