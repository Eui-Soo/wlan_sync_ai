function [add_ppm, cfo] = ppm_insert(ch_out,fc, fclk, maxppm)

ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
cfo = (fc/1e6) * ppm;   % [tolerence]

add_ppm = ch_out.*exp(1j*2*pi*(cfo/fclk)*[1:length(ch_out)]);