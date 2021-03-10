clc
clear

cfgHT = wlanHTConfig;
tgn = wlanTGnChannel;
txWaveform = wlanWaveformGenerator([1;0;0;1],cfgHT);
txWaveform = [zeros(100,1);txWaveform];
SNR = 20; % In decibels
fadedSig = tgn(txWaveform);
rxWaveform = awgn(fadedSig,SNR,0);
startOffset = wlanPacketDetect(rxWaveform,cfgHT.ChannelBandwidth);
ind = wlanFieldIndices(cfgHT);
nonHTFields = rxWaveform(startOffset+(ind.LSTF(1):ind.LSIG(2)),:);

[startOffset,M] = wlanSymbolTimingEstimate(nonHTFields,cfgHT.ChannelBandwidth);