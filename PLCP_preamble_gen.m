function [preamble] = PLCP_preamble_gen(N_fft,over_s)%N_fft=64, cp=16
fft_size=N_fft*over_s;
% short training sequence
S = sqrt(13/6)*[ 0,0,1+1j,0,0,0,-1-1j,0,0,0,1+1j,0,0,0,-1-1j,0,0,0,-1-1j,0,0,0,1+1j,...
    0,0,0,0,0,0,0,-1-1j,0,0,0,-1-1j,0,0,0,1+1j,0,0,0,1+1j,0,0,0,1+1j,0,0,0,1+1j,0,0 ];
S = [ zeros(1,6) S zeros(1,5) ];
sort_S = [S(length(S)/2+1:end) zeros(1,fft_size-N_fft) S(1:length(S)/2)];
% long training sequence
L = [1,1,-1,-1,1,1,-1,1,-1,1,1,1,1,1,1,-1,-1,1,1,-1,1,-1,1,1, 1,1,0,...
    1,-1,-1,1,1,-1,1,-1,1,-1,-1,-1,-1,-1,1,1,-1,-1,1,-1,1,-1,1,1,1,1];
L = [zeros(1,6) L zeros(1,5)];
sort_L = [L(length(L)/2+1:end) zeros(1,fft_size-N_fft) L(1:length(L)/2)];
% ifft
S_ifft = ifft(sort_S, fft_size);
L_ifft = ifft(sort_L,fft_size);
S_norm = S_ifft*sqrt(fft_size);
L_norm = L_ifft*sqrt(fft_size);
% inserting cyclic prefix
S_pre = [S_norm(length(S_norm)*3/4+1:end) S_norm S_norm(length(S_norm)*3/4+1:end) S_norm];
L_pre = [L_norm(length(L_norm)/2+1:end) L_norm L_norm];
preamble = [S_pre L_pre];



% save
save S_norm S_norm;
% save S_pre S_pre;
save L_norm L_norm;
save preamble preamble;

%% freq. domain
% figure(71); hold off;
% plot_var = S_norm;
% [Pxx,F] = pwelch(plot_var,[],[],[],20);
% Pxx = fftshift(Pxx);
% plot(F-max(F)/2,10*log10(abs(Pxx))); grid on;
% xlabel('MHz');
