clc
clear
close all


fc =5.3e9;   % [kHz] % Carrier Frequency
fclk = 40e6; % sampling frequency
maxppm =40;
N_set=50000;
L_window=864;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);
timing_range=224;


cfgVHT = wlanVHTConfig('ChannelBandwidth','CBW40');
cfgVHT.NumTransmitAntennas = 1;
cfgVHT.NumSpaceTimeStreams = 1;
tgnChan = wlanTGacChannel;
tgnChan.SampleRate = fclk;
tgnChan.ChannelBandwidth='CBW40';
tgnChan.CarrierFrequency=fc;
tgnChan.DelayProfile = 'Model-F';
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

SNR=-10:30;
for SNR_loop=1:length(SNR)
    Test_rx_data=zeros(26624,N_set);
    Test_cfo_label=zeros(1,N_set);
    Test_timing_label_idx=zeros(1,N_set);
    %% transmission & channel & noise
    temp=zeros(length(tx_sig_tmp),1);
    for iter=1:N_set
        %     SNR_dB = -10+40*rand(1);
        No = 10.^(-SNR_dB/10); % Noise power assuming signal power = 1
        txPSDU = randi([0 1],cfgVHT.PSDULength*8,1); % Generate PSDU data in bits
        data = wlanVHTData(txPSDU,cfgVHT);
        
        starting_idx=randi([0 timing_range-1]);
        
        tx_sig_tmp=[zeros(length(STF),1);zeros(starting_idx,1);STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];
        %     tx_sig_tmp=[ones(1,1);zeros(50,1)];
        reset(tgnChan); % Reset channel for different realization
        [tx_sig,h] = tgnChan(tx_sig_tmp);
        Nawgn = complex_awgn_gen(No,length(tx_sig)); %AWGN channel
        tx_out=tx_sig+Nawgn;
        ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
        
        cfo = fc * ppm/1e6;   % [tolerence]
        %
        pfOffset = comm.PhaseFrequencyOffset('SampleRate',fclk,'FrequencyOffsetSource','Input port');
        rx_in = pfOffset(tx_out,cfo);
        
        Test_rx_data(1:length(rx_in),iter)=rx_in;
        Test_cfo_label(iter)=cfo;
        Test_timing_label_idx(iter)=starting_idx;
        if mod(iter,100)==0
            iter
        end
    end
    S=sprintf("wlan_train_set_model_F");
    save(S,'Train_data','Train_cfo_label','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
    S1=sprintf("wlan_train_set_timing_model_F");
    save(S1,'Train_data_timing','Train_timing_label_onehot','Train_timing_label_idx','-v7.3')
    S2=sprintf("wlan_train_set_cfo_model_F");
    save(S2,'Train_data_cfo','Train_cfo_label','-v7.3')
end
