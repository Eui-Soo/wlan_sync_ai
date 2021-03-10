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
L_window=1024;
XTrain = zeros(N_set,L_window);
YTrain = zeros(1,N_set);
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
% stem(preamble,'b')
% grid on
% xlabel('time')
% axis([0 160*over_s -0.6 0.6])
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);


for loop=1:N_set
    %% Data part
    %% data
    SNR=10;%-20+30*rand(1);
    label=randi([1 L_window-320],1,1);
    user_data = randi([0 1],1,N_bit);
    data = data_gen(user_data, N_fft, Rate);
    %% tx signal generation
    tx_data = [preamble signal data] ;
    rx_data=[zeros(1,label) tx_data];
    noise =sqrt(0.5*10^(-SNR/10))*(crandn(1,length(rx_data)));
    yesno=1;%randi([0 1],1);
    if yesno==1
        rx_data=rx_data+noise;
    else
        rx_data=noise;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% receiver side %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    corr = zeros(1,L_window);
    register=rx_data(17:32);
    for n = 1:L_window
        corr(n)=(abs(sum((rx_data(n:n+16-1).*conj(register)))).^2)/((sum(abs(register).^2))^2);            
        register=circshift(register,-1);
        register(end)=rx_data(n+32); 
    end
    idx=label+160;
        plot(corr,'b');
%         hold on
%         plot(TH,'r')
    grid on;
    axis([0 L_window 0 1.3])
    S=sprintf('%d, %02f, %d',idx,SNR,yesno);
%     title(S);
    hold off
%     xlabel('sample index n')
%     ylabel('')
    max_value=max(corr);
    corr=corr/max_value;
    
%     figure(74); hold off;

%     
    corr2=reshape(corr,16,L_window/16);
%     figure(3)
%      imshow(corr)
    XTrain(:,:,1,loop) = corr;
    YTrain(1,loop)=idx;
end
S = sprintf('data_train_set_papaer_1d');
save(S, 'XTrain','YTrain','-v7.3');
S = sprintf('data_train_set_papaer_2d');
save(S, 'XTrain2','YTrain2','-v7.3');