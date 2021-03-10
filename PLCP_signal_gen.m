function signal = PLCP_signal_gen(N_fft,Rate,over_s)
% N_fft=64;
% Rate=6;
% PLCP signal generation
fft_size=over_s*N_fft;
if Rate == 6
    rate_bits = [1 1 0 1]; % Rate = 6 Mbps < BPSK >
elseif Rate == 9
    rate_bits = [1 1 1 1]; % Rate = 9 Mbps < BPSK >
elseif Rate == 12
    rate_bits = [0 1 0 1]; % Rate = 12 Mbps < QPSK >
elseif Rate == 18
    rate_bits = [0 1 1 1]; % Rate = 18 Mbps < QPSK >
elseif Rate == 24
    rate_bits = [1 0 0 1]; % Rate = 24 Mbps < 16QAM >
elseif Rate == 36
    rate_bits = [1 0 1 1]; % Rate = 36 Mbps < 16QAM >
elseif Rate == 48
    rate_bits = [0 0 0 1]; % Rate = 48 Mbps < 64QAM >
elseif Rate == 54
    rate_bits = [0 0 1 1]; % Rate = 54 Mbps < 64QAM >
end

packet_length = zeros(1,12); % packet length
reserved_bit = 0;
parity_bit = 0;
tail_bit = zeros(1,6);
if N_fft==64
    PLCP_signal = [rate_bits reserved_bit packet_length parity_bit tail_bit];  % 4bits for Rate / 12bits for Length / 6bits for Signal tail
elseif N_fft==128
    ac_802_11=randi([])
end

% FEC < convolution code 1/2 >
trel = poly2trellis(7,[171 133]); % trellis for 1/2 code
signal_enc = convenc(PLCP_signal,trel); % encoding data
signal_sym = BPSKMODU(signal_enc); % mapping
signal_p = pilot_insertion(signal_sym,N_fft); % add pilot
signal_shift = [ signal_p(1:length(signal_p)/2) 0 signal_p(length(signal_p)/2+1:end) ];
if N_fft==64
    signal_g = [ zeros(1,6) signal_shift zeros(1,5) ]; % add gard
elseif N_fft==128
    signal_g = [ zeros(1,10) signal_shift zeros(1,9) ]; % add gard
end
signal_sort = [ signal_g(length(signal_g)/2+1:end) zeros(1,fft_size-N_fft) signal_g(1:length(signal_g)/2) ]; % ifft sort

signal_ifft = ifft(signal_sort, fft_size); % ifft
signal_ifft = signal_ifft*sqrt(fft_size);

signal = [ signal_ifft(length(signal_ifft)*3/4+1:end) signal_ifft ]; % inserting cyclic prefix

