function rx_data = frame_sync(add_ppm)

load S_norm;
load L_norm;
load preamble;

rx_sig = [L_norm L_norm];   % preamble to synchronize
L_corr = length(rx_sig);    % correlation length
mean_pwr = mean(abs(rx_sig(1:L_corr)).^2);

window = length(add_ppm)-length(L_norm)*2;  % window size
corr = zeros(1,window);

for n = 1:window
    corr(n) = rx_sig*add_ppm(n:n+length(L_norm)*2-1)'/L_corr/mean_pwr;
end

[Y,I] = max(abs(corr));
save I I;

rx_data = add_ppm(I-length(L_norm)/2:end);

% correlation
figure(74); hold off;
plot(abs(corr),'b');
grid on;
title('correlation');
% axis([0 1200 0 200]);