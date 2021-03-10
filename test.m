clc
clear
close all
cfgVHT = wlanVHTConfig('ChannelBandwidth','CBW20');
y = wlanLSTF(cfgVHT);
size(y)

a=PLCP_preamble_gen(64,1);
plot(abs(y))
hold on
plot(abs(a(1:160)))