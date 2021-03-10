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
N_set=10000;
L_window=2500;

%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate);
SNR=[-18:0];
for SNR_loop=1:length(SNR)
    XTest = zeros(N_set,L_window);
    YTest = zeros(N_set,L_window);
    for loop=1:N_set
        %% Data part
        %% data
        label=randi([1 L_window-320],1,1);
        user_data = randi([0 1],1,N_bit);
        data = data_gen(user_data, N_fft, Rate);
        %% tx signal generation
        tx_data = [preamble signal data] ;
        % tx_data = tx_data/mean(abs(tx_data).^2);
        % [rx_data, cfo] = ppm_insert(tx_data, fc, fclk, maxppm);
        rx_data=[zeros(1,label) tx_data];
        [rx_data, cfo] = ppm_insert(rx_data, fc, fclk, maxppm);
        noise = sqrt(0.5*10^(-SNR(SNR_loop)/10))*(crandn(1,length(rx_data)));
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
            corr(n) = abs(flip(rx_sig)*register'/L_corr/mean_pwr).^2;
        end
        max_value=max(corr);
        corr=corr/max_value;
        idx=label+160;
        %     corr=reshape(corr,100,100).';
        
        XTest(loop,:) = corr;
        YTest(loop,idx)=1;
    end
    S = sprintf('data_test_set_SNR(%d)_v2',SNR(SNR_loop))
    save(S, 'XTest','YTest','-v7.3');
end