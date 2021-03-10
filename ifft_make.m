function y = ifft_make(x, fft_pt)

L = length(x);
y = zeros(1,L);

% ifft
for n = 1:L/fft_pt
    y(fft_pt*(n-1)+1:fft_pt*n) = ifft(x(fft_pt*(n-1)+1:fft_pt*n),fft_pt);
end
