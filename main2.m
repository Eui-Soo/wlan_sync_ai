clc
clear
close all

%% para
N_bit=4800;
N_fft=64;
Rate=6;
% Rate = 6 Mbps < BPSK >
% Rate = 9 Mbps < BPSK >
% Rate = 12 Mbps < QPSK >
% Rate = 18 Mbps < QPSK >
% Rate = 24 Mbps < 16QAM >
% Rate = 36 Mbps < 16QAM >
% Rate = 48 Mbps < 64QAM >
% Rate = 54 Mbps < 64QAM >

fc = 2.4e9;   % [Hz] % Carrier Frequency
fclk = 20e6; % sampling frequency
maxppm = 0;
N_set=100000;
L_window=10000;
XTrain = zeros(100,100,1,N_set);
YTrain = zeros(N_set,1);
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate);


for loop=1:N_set
    %% Data part
    %% data
    SNR=-15+25*rand(1);
    label=randi([1 9500],1,1);
    user_data = randi([0 1],1,N_bit);
    data = data_gen(user_data, N_fft, Rate);
    %% tx signal generation
    tx_data = [preamble signal data] ;
    % tx_data = tx_data/mean(abs(tx_data).^2);
    % [rx_data, cfo] = ppm_insert(tx_data, fc, fclk, maxppm);
    rx_data=[zeros(1,label) tx_data];
    [rx_data, cfo] = ppm_insert(rx_data, fc, fclk, maxppm);
    noise = sqrt(0.5*10^(-SNR/10))*(crandn(1,length(rx_data)));
    rx_data=rx_data+noise;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% receiver side %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rx_sig = [preamble(1:160)];   % preamble to synchronize
    L_corr = length(rx_sig);    % correlation length
    mean_pwr = mean(abs(rx_sig(1:L_corr)).^2);
    corr = zeros(1,L_window);
    register=zeros(1,length(rx_sig));
    for n = 1:L_window
        register=circshift(register,1);
        register(1)=rx_data(n);
        corr(n) = flip(rx_sig)*register'/L_corr/mean_pwr;
    end
    max_value=max(corr);
    corr=corr/max_value;
    figure(74); hold off;
    plot(abs(corr),'b');
    grid on;
    title('correlation');
    corr=reshape(corr,100,100).';
   
%     XTrain(:,:,1,loop) = corr;
%     YTrain(loop,1)=label+160;
end
S = sprintf('data_train_set_v4');
save(S, 'XTrain','YTrain','-v7.3');