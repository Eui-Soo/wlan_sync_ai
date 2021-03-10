function data = data_gen(user_data, N_fft, Rate)
% set-up
service_16 = zeros(1,16); % 16bits for service
tail_6 = zeros(1,6); % 6bits for tail
pad_2 = zeros(1,2); % 2bits for pad

data_temp = [service_16 user_data tail_6 pad_2];
data_enc = conv_fec(data_temp,Rate); % encoding data
% mapping
data_sym = mapping(data_enc, Rate); % QPSK
% add pilot
data_p = pilot_insertion(data_sym,N_fft);
data_shift = ifft_sort(data_p,N_fft); % ifft sort
data_fft = ifft_make(data_shift,N_fft); % ifft
data_fft = data_fft*sqrt(N_fft);  % normalize
data = cp_insert(data_fft,N_fft); % inserting cyclic prefix
