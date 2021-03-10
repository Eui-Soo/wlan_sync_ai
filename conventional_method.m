clc
clear
close all


fc =5.3e9;   % [kHz] % Carrier Frequency
fclk = 40e6; % sampling frequency
maxppm =40;
N_set=10000;
L_window=864;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);



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
tgnChan.TransmitReceiveDistance = 1; % Distance in meters for NLOS
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
SNR=-15:18;%[-14,-13,-11,-10,-8,-7,-5,-4,-2,-1,1,2,4,5,7,8,10,11,13,14,16,17];
for SNR_loop=1:length(SNR)
    %% transmission & channel & noise
    timing_range=224;
    con_timing=zeros(1,N_set);
    con_cfo=zeros(1,N_set);
    Test_cfo_label=zeros(1,N_set);
    Test_timing_label_idx=zeros(1,N_set);
    for iter=1:N_set
        
        No = 10.^(-SNR(SNR_loop)/10); % Noise power assuming signal power = 1
        txPSDU = randi([0 1],cfgVHT.PSDULength*8,1); % Generate PSDU data in bits
        data = wlanVHTData(txPSDU,cfgVHT);
        
        starting_idx=randi([0 timing_range-1]);
        
        tx_sig=[zeros(length(STF),1);zeros(starting_idx,1);STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];
             
        
        Nawgn = complex_awgn_gen(No,length(tx_sig)); %AWGN channel
        tx_out=tx_sig+Nawgn;
        ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
        
        cfo = fc * ppm/1e6;   % [tolerence]
        
        pfOffset = comm.PhaseFrequencyOffset('SampleRate',fclk,'FrequencyOffsetSource','Input port');
        rx_in = pfOffset(tx_out,cfo);

        %% conventional
        % [startOffset,M] = wlanPacketDetect(rx_in,cfgVHT.ChannelBandwidth);
        % coarse_timing_field=rx_in(startOffset+1:end);
        
        ind = wlanFieldIndices(cfgVHT);
        coarse_cfo_field=rx_in(ind.LSTF(1)+length(STF)+timing_range:ind.LSTF(2)+length(STF)+timing_range);
        foffset1 = wlanCoarseCFOEstimate(coarse_cfo_field,cfgVHT.ChannelBandwidth);
        fine_cfo_field=pfOffset(rx_in,-foffset1);
        
%         nonhtfields = fine_cfo_field(ind.LSTF(1)+length(STF):ind.VHTSIGA(2)+length(STF));
        nonhtfields = fine_cfo_field(ind.LSTF(1)+length(STF)+timing_range:ind.LLTF(2)+length(STF)+timing_range);
        [startOffset,M] = wlanSymbolTimingEstimate(nonhtfields ,cfgVHT.ChannelBandwidth);
%         figure(2)
%         plot(M)
        rxltf1 = fine_cfo_field(length(LTF)+startOffset+length(STF):2*length(LTF)+startOffset-1+length(STF));
        foffset2 = wlanFineCFOEstimate(rxltf1,cfgVHT.ChannelBandwidth);
        con_cfo(iter)=foffset1+foffset2;
        con_timing(iter)=timing_range+startOffset;
        Test_cfo_label(iter)=cfo;
        Test_timing_label_idx(iter)=starting_idx;
%                 foffset1+foffset2
%                 timing_range+startOffset
%                 starting_idx
        if mod(iter,100)==0
            iter
        end
    end
    S3=sprintf("wlan_conventional_SNR(%d)",SNR(SNR_loop));
    save(S3,'con_cfo','con_timing','Test_cfo_label','Test_timing_label_idx','-v7.3')
end
% figure(2)
% imshow(corr)
% stem(starting_idx+320,1,'r')
% hold on
% plot(corr,'b','linewidth',2)

