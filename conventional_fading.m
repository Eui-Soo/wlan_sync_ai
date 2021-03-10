clc
clear
close all


fc =5.3e9;   % [kHz] % Carrier Frequency
fclk = 40e6; % sampling frequency
maxppm =40;
N_set=1000;
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
tgnChan.DelayProfile = 'Model-F';
tgnChan.NumTransmitAntennas = cfgVHT.NumTransmitAntennas;
tgnChan.NumReceiveAntennas = 1;
tgnChan.TransmitReceiveDistance = 3; % Distance in meters for NLOS
tgnChan.TransmissionDirection='Downlink';
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
SNR=30;%-15:18;%[-14,-13,-11,-10,-8,-7,-5,-4,-2,-1,1,2,4,5,7,8,10,11,13,14,16,17];
for SNR_loop=1:length(SNR)
    %% transmission & channel & noise
    timing_range=224;
    ch_impluse_buf=[zeros(640,1)];
    for iter=1:N_set
        %         iter
        No = 10.^(-SNR(SNR_loop)/10); % Noise power assuming signal power = 1
        txPSDU = randi([0 1],cfgVHT.PSDULength*8,1); % Generate PSDU data in bits
        data = wlanVHTData(txPSDU,cfgVHT);
        
        starting_idx=0;%randi([0 timing_range-1]);
        
        tx_sig_tmp=[zeros(length(STF),1);zeros(starting_idx,1);STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];
        %         tx_sig_tmp=[STF;LTF;SIG;VHTSIGA;VHTSTF;VHTLTF;VHTSIGB;data];
        %         tx_sig_tmp=[1;zeros(639,1)];
        reset(tgnChan); % Reset channel for different realization
        [tx_sig,h]=tgnChan(tx_sig_tmp);
        [delay,mag] = channelDelay(h,info(tgnChan).ChannelFilterCoefficients);
        delay
        figure(66)
        stem(mag)
        %         for n=1:length(ch_impluse_buf)
        %            if abs(tx_sig_tmp2(n))>=abs(ch_impluse_buf(n))
        %                ch_impluse_buf(n)=tx_sig_tmp2(n);
        %            end
        %         end
        %         ch_impluse_buf=ch_impluse_buf+tx_sig_tmp2;
        %         figure(5)
        %         stem(abs(h(1,:)))
        %         figure(6)
        %         hold off
        %         stem(abs(tx_sig_tmp2),'r')
        %         hold on
        %         stem(abs(tx_sig_tmp),'b')
        %         axis([0 50 0 2.4])
        %         hold on
        %         plot(imag(tx_sig_tmp2),'b')
        %         tx_sig=[zeros(length(STF),1);tx_sig_tmp2];
        Nawgn = complex_awgn_gen(No,length(tx_sig)); %AWGN channel
        tx_out=tx_sig+Nawgn;
        ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
        
        cfo = 0;%fc * ppm/1e6;   % [tolerence]
        
        pfOffset = comm.PhaseFrequencyOffset('SampleRate',fclk,'FrequencyOffsetSource','Input port');
        rx_in = pfOffset(tx_out,cfo);
        
        %% conventional
        % [startOffset,M] = wlanPacketDetect(rx_in,cfgVHT.ChannelBandwidth);
        % coarse_timing_field=rx_in(startOffset+1:end);
        
        ind = wlanFieldIndices(cfgVHT);
        coarse_cfo_field=rx_in(ind.LSTF(1)+length(STF):ind.LSTF(2)+length(STF));
        foffset1 = wlanCoarseCFOEstimate(coarse_cfo_field,cfgVHT.ChannelBandwidth);
        fine_cfo_field=pfOffset(rx_in,-foffset1);
        
        nonhtfields = fine_cfo_field(ind.LSTF(1)+length(STF):ind.VHTSIGA(2)+length(STF));
        %         nonhtfields = fine_cfo_field(ind.LSTF(1)+length(STF)+timing_range:ind.LLTF(2)+length(STF)+timing_range);
        [startOffset,M] = wlanSymbolTimingEstimate(nonhtfields ,cfgVHT.ChannelBandwidth);
        figure(2)
        plot(M)
        rxltf1 = fine_cfo_field(length(LTF)+startOffset+length(STF):2*length(LTF)+startOffset-1+length(STF));
        foffset2 = wlanFineCFOEstimate(rxltf1,cfgVHT.ChannelBandwidth);
%         foffset1+foffset2
%         cfo
%         startOffset
%         starting_idx
        if mod(iter,100)==0
            iter
        end
    end
    
end

% figure(2)
% imshow(corr)
% stem(starting_idx+320,1,'r')
% hold on
% plot(corr,'b','linewidth',2)

