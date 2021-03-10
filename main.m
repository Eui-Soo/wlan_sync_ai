clc
clear
close all
N_fft=64;
preamble = PLCP_preamble_gen(N_fft);
data =[preamble crand(1,500)] ;
short_preamble=preamble(1:160);
long_preamble=preamble(161:end);
signal_preamble=short_preamble(1:16*7);
timing_preamble=short_preamble(16*7+1:end);
register_signal=zeros(1,length(signal_preamble));
register_timing=zeros(1,length(timing_preamble));
register_long=zeros(1,length(long_preamble));
register=zeros(1,length(preamble));
corr_signal_detection=zeros(1,length(data));
corr_timing_offset=zeros(1,length(data));
corr_long=zeros(1,length(data));
corr=zeros(1,length(data));
for n=1:length(data)
    register_signal=circshift(register_signal,1);
    register_signal(1)=data(n);
    register_timing=circshift(register_timing,1);
    register_timing(1)=data(n); 
    register_long=circshift(register_long,1);
    register_long(1)=data(n); 
    register=circshift(register,1);
    register(1)=data(n); 
    corr_signal_detection(n)=abs(sum(register_signal.*flip(signal_preamble)))^2;
    corr_timing_offset(n)=abs(sum(register_timing.*flip(timing_preamble)))^2;
    corr_long(n)=abs(sum(register_long.*flip(long_preamble)))^2;
    corr(n)=abs(sum(register.*flip(preamble)))^2;
end
figure(1)
plot(corr_signal_detection)
figure(2)
plot(corr_timing_offset)
figure(3)
plot(corr_long)
figure(4)
plot(corr)
figure(5)
plot(abs(data))