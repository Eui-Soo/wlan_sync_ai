clc
clear
close all


fc =5.3e9;   % [kHz] % Carrier Frequency
fclk = 40e6; % sampling frequency
maxppm =40;
N_set=100000;
L_window=864;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);
timing_range=224;
Train_data=zeros(1,L_window,cfo_com,N_set);
Train_data_timing=zeros(1,L_window,1,N_set);
Train_data_cfo=zeros(1,cfo_com,1,N_set);
Train_cfo_label=zeros(1,N_set);
Train_timing_label_onehot=zeros(timing_range,N_set);
Train_timing_label_idx=zeros(1,N_set);

cfgVHT = wlanVHTConfig('ChannelBandwidth','CBW40');
cfgVHT.NumTransmitAntennas = 1;
cfgVHT.NumSpaceTimeStreams = 1;
tgnChan = wlanTGacChannel;
tgnChan.SampleRate = fclk;
tgnChan.ChannelBandwidth='CBW40';
tgnChan.CarrierFrequency=fc;
tgnChan.DelayProfile = 'Model-B';
tgnChan.NumTransmitAntennas = cfgVHT.NumTransmitAntennas;
tgnChan.NumReceiveAntennas = 1;
tgnChan.TransmitReceiveDistance = 5; % Distance in meters for NLOS
tgnChan.TransmissionDirection='Uplink';
tgnChan.LargeScaleFadingEffect = 'None';%'None', 'Pathloss', 'Shadowing', or 'Pathloss and shadowing'
tgnChan.PathGainsOutputPort = 1;

STF = wlanLSTF(cfgVHT);
LTF = wlanLLTF(cfgVHT);
SIG = wlanLSIG(cfgVHT);
VHTSIGA = wlanVHTSIGA(cfgVHT);
VHTSTF = wlanVHTSTF(cfgVHT);
VHTLTF = wlanVHTLTF(cfgVHT);
VHTSIGB = wlanVHTSIGB(cfgVHT);
% rng(0) % Initialize the random number generator
%% transmission & channel & noise
% tx_sig_tmp=[ones(1,1);zeros(100,1)];
% temp=zeros(length(tx_sig_tmp),1);
for iter=1:N_set
    SNR_dB = -10+40*rand(1);
    No = 10.^(-SNR_dB/10); % Noise power assuming signal power = 1
    txPSDU = randi([0 1],cfgVHT.PSDULength*8,1); % Generate PSDU data in bits
    data = wlanVHTData(txPSDU,cfgVHT);
    
    starting_idx=randi([0 timing_range-3]);
    
    tx_sig_tmp=[zeros(length(STF),1);zeros(starting_idx,1);STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];
%     tx_sig_tmp=[ones(1,1);zeros(100,1)];
    reset(tgnChan); % Reset channel for different realization
    [tx_sig,h] = tgnChan(tx_sig_tmp);
    [delay,mag] = channelDelay(h,info(tgnChan).ChannelFilterCoefficients);
    ch_delay_filter=info(tgnChan).ChannelFilterDelay;
%     for n=1:length(tx_sig)
%        if abs(temp(n))<abs(tx_sig(n))
%            temp(n)=tx_sig(n);
%        end
%     end
%     
%     x_range=linspace(0,1250,length(tx_sig));
%     figure(1);hold off;
%     stem(x_range-25*7,abs(temp));
    
    Nawgn = complex_awgn_gen(No,length(tx_sig)); %AWGN channel
    tx_out=tx_sig+Nawgn;
    ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
    
    cfo = fc * ppm/1e6;   % [tolerence]
%     
    pfOffset = comm.PhaseFrequencyOffset('SampleRate',fclk,'FrequencyOffsetSource','Input port');
    rx_in = pfOffset(tx_out,cfo);
%     saScope = dsp. SpectrumAnalyzer ( 'SampleRate' , fclk);
%     saScope (rx_in)
    
    
    %     %% proposed
    corr = zeros(L_window,cfo_com);
    preamble=[STF.'];
    register=zeros(1,length(preamble));
    for cfo_loop=1:cfo_com
        rx_cfo_tmp=(rx_in.').*exp(-1j*2*pi*(cfo_range(cfo_loop)/fclk)*[1:length(rx_in)]);
        for n = 1:L_window
            register=rx_cfo_tmp(n:length(preamble)+n-1);
            tmp=sum(register.*conj(preamble));
            corr(n,cfo_loop) = abs(tmp).^2;
        end
    end
    corr=corr/max(max(corr));
    [B,idx1]=max(corr);
    [A,idx2]=max(B);
%     idx1(idx2)
    
%     (delay-ch_delay_filter)
    Train_data(1,:,:,iter)=corr;
    Train_data_timing(1,:,1,iter)=corr(:,idx2);
    Train_data_cfo(1,:,1,iter)=corr(idx1(idx2),:);
    Train_cfo_label(iter)=cfo;
    Train_timing_label_onehot(starting_idx+1+(delay-ch_delay_filter),iter)=1;
    Train_timing_label_idx(iter)=starting_idx;

    
%     delay
%     starting_idx+328
%     figure(2)
%     hold off
%     plot(mag)
%     plot(corr(:,idx2))
%     figure(1)
%     hold off
%     mesh(cfo_range/1e3,864:-1:1,corr)
%     xlabel('Frequency spacing[kHz]')
%     ylabel('sample index')
%     axis('tight')
%     view(90,0)
%     figure(2)
%     imshow(corr)
%     figure(2)
%     hold off
%     plot(corr(idx1(idx2),:))
%     figure(3)
%     hold off
%     plot(corr(:,idx2))
    % %
    
    
    if mod(iter,100)==0
        iter
    end
end
%     x_range=linspace(0,2500,length(tx_sig));
%     x_range=0:1/fclk:5;
%     figure(1);hold off;
%     stem((x_range(1:length(temp))-(1/fclk)*7)/1e-9,abs(temp));
%     xlabel('Time(ns)')
%     axis([-300 1200 0 max(abs(temp))])
%     grid on
%     A=info(tgnChan);
S=sprintf("wlan_train_set_model_B_v2");
save(S,'Train_data','Train_cfo_label','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
% S1=sprintf("wlan_train_set_timing_model_B_v2");
% save(S1,'Train_data_timing','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
% S2=sprintf("wlan_train_set_cfo_model_F_v2");
% save(S2,'Train_data_cfo','Train_cfo_label','-v7.3')

