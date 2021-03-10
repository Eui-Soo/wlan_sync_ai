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
tgnChan.TransmitReceiveDistance = 3; % Distance in meters for NLOS
tgnChan.TransmissionDirection='Uplink';
tgnChan.LargeScaleFadingEffect = 'None';%'None', 'Pathloss', 'Shadowing', or 'Pathloss and shadowing'
STF = wlanLSTF(cfgVHT);
LTF = wlanLLTF(cfgVHT);
SIG = wlanLSIG(cfgVHT);
VHTSIGA = wlanVHTSIGA(cfgVHT);
VHTSTF = wlanVHTSTF(cfgVHT);
VHTLTF = wlanVHTLTF(cfgVHT);
VHTSIGB = wlanVHTSIGB(cfgVHT);
% rng(0) % Initialize the random number generator
%% transmission & channel & noise
for iter=1:N_set
    SNR_dB = 50;%-10+30*rand(1);
    No = 10.^(-SNR_dB/10); % Noise power assuming signal power = 1
    txPSDU = randi([0 1],cfgVHT.PSDULength*8,1); % Generate PSDU data in bits
    data = wlanVHTData(txPSDU,cfgVHT);
    
    starting_idx=100;%randi([0 timing_range-1]);
    
    tx_sig=[zeros(length(STF),1);zeros(starting_idx,1);STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];

%     reset(tgnChan); % Reset channel for different realization
%     tx_sig = tgnChan(tx_sig_tmp);
    Nawgn = complex_awgn_gen(No,length(tx_sig)); %AWGN channel
    tx_out=tx_sig+Nawgn;
    ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
    
    cfo = 0;%fc * ppm/1e6;   % [tolerence]
    
    pfOffset = comm.PhaseFrequencyOffset('SampleRate',fclk,'FrequencyOffsetSource','Input port');
    rx_in = pfOffset(tx_out,cfo);
    
    
    
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
Train_data(1,:,:,iter)=corr;
Train_data_timing(1,:,1,iter)=corr(:,idx2);
Train_data_cfo(1,:,1,iter)=corr(idx1(idx2),:);
Train_cfo_label(iter)=cfo;
Train_timing_label_onehot(starting_idx+1,iter)=1;
Train_timing_label_idx(iter)=starting_idx;
figure(1)
hold off
mesh(cfo_range/1e3,864:-1:1,corr)
% xlabel('Frequency spacing[kHz]')
% ylabel('sample index')
axis('tight')
view(90,0)
% figure(2)
% imshow(corr)
% figure(2)
% hold off
% plot(corr(idx1(idx2),:))
% figure(3)
% hold off
% plot(corr(:,idx2))
% % %
%     
%% conventional
% [startOffset,M] = wlanPacketDetect(rx_in,cfgVHT.ChannelBandwidth);
% coarse_timing_field=rx_in(startOffset+1:end);

% ind = wlanFieldIndices(cfgVHT);
% coarse_cfo_field=rx_in(ind.LSTF(1):ind.LSTF(2));
% foffset1 = wlanCoarseCFOEstimate(coarse_cfo_field,cfgVHT.ChannelBandwidth);
% fine_cfo_field=pfOffset(rx_in,-foffset1);
% 
% nonhtfields = fine_cfo_field(ind.LSTF(1):ind.LSIG(2));
% [startOffset,M] = wlanSymbolTimingEstimate(nonhtfields ,cfgVHT.ChannelBandwidth);
% 
% rxltf1 = fine_cfo_field(length(LTF)+startOffset:2*length(LTF)+startOffset-1);
% foffset2 = wlanFineCFOEstimate(rxltf1,cfgVHT.ChannelBandwidth);

if mod(iter,100)==0
    iter
end
end
S=sprintf("wlan_train_set_joint_v3");
save(S,'Train_data','Train_cfo_label','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
S1=sprintf("wlan_train_set_timing_v3");
save(S1,'Train_data_timing','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
S2=sprintf("wlan_train_set_cfo_v3");
save(S2,'Train_data_cfo','Train_cfo_label','-v7.3')
% figure(2)
% imshow(corr)
% stem(starting_idx+320,1,'r')
% hold on
% plot(corr,'b','linewidth',2)

