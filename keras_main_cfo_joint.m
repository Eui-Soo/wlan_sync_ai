clc
clear
close all

%% para
N_bit=4800;
N_fft=64;
Rate=6;
fc = 2.4e6;   % [kHz] % Carrier Frequency
fclk = 20e3; % sampling frequency
maxppm =20;
N_set=100000;
L_window=4096;
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);
cfo_com=24;
cfo_range=-(fc*maxppm/1e6):cfo_com:(fc*maxppm/1e6);
cfo_s=-48:.02:48;
XTrain = zeros(N_set,length(cfo_range),L_window);
YTrain = zeros(N_set,1);
YTrain2 = zeros(N_set,2);
for loop=1:N_set
%     loop
    %% Data part
    %% data
    SNR=-10+40*rand(1);
    label=randi([1 L_window-320],1,1);
    user_data = randi([0 1],1,N_bit);
    data = data_gen(user_data, N_fft, Rate);
    %% tx signal generation
    tx_data = [preamble signal data] ;

        rx_data=[zeros(1,label) tx_data];

    noise =sqrt(0.5*10^(-SNR/10))*(crandn(1,length(rx_data)));
    rx_data=rx_data+noise;
    ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
    cfo = fc * ppm/1e6;   % [tolerence]
    
    add_ppm = rx_data.*exp(1j*2*pi*(cfo/fclk)*[1:length(rx_data)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% receiver side %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rx_sig = preamble(1:length(preamble)/2);   % preamble to synchronize

    corr = zeros(length(cfo_range),L_window);
    register=zeros(1,length(rx_sig));
    for cfo_loop=1:length(cfo_range)
        temp=add_ppm.*exp(-1j*2*pi*(cfo_range(cfo_loop)/fclk)*[1:length(add_ppm)]);
        for n = 1:L_window
            register=circshift(register,-1);
            register(end)=temp(n);

            tmp=sum(register.*conj(rx_sig));
            corr(cfo_loop,n) = abs(tmp).^2;
            
        end
    end
    [label_cfo,cfo_index]=min(abs(cfo_s-cfo));
    corr=corr/max(max(corr));
%     mesh(corr)
    XTrain(loop,:,:) = corr;
    YTrain(loop,:)=label+160;
    YTrain2(loop,1)=label+160;
    YTrain2(loop,2)=cfo_s(cfo_index);
end
S = sprintf('keras_train_set_cfo(%d)_joint',cfo_com);
save(S, 'XTrain','YTrain','YTrain2','-v7.3');