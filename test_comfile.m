clc
clear

SNR=5;
RMSE=zeros(1,length(SNR));
for n=1:length(SNR)
    S=sprintf('test_set(%d)',SNR(n));
    S1=sprintf('test_set_cfo_re_label(%d)',SNR(n));
    load(S)
    load(S1)    
    hold off
    mesh(1:1024,linspace(-212,212,11),Test_data(:,:,n));
end