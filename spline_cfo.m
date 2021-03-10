clc
clear
close all

SNR=-10:5;
RMSE=zeros(1,length(SNR));
fc =5.3e6;   % [kHz] % Carrier Frequency
fclk = 40e3; % sampling frequency
maxppm =40;
N_set=5000;
L_window=1024;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);
for SNR_loop=1:length(SNR)
    S=sprintf('test_set(%d).mat',SNR(SNR_loop));
    load(S)
    S1=sprintf('test_set_cfo_re_label(%d).mat',SNR(SNR_loop));
    load(S1)
    for m=1:5000
        cfo_block=zeros(1,11);
        for n=1:11
            cfo_block(n)= max(Test_data(n,:,m));
        end
        [a,tmp]=max(spline(cfo_range,cfo_block,xx));
        est=xx(tmp);
        RMSE(SNR_loop)= RMSE(SNR_loop)+ (est-Test_cfo_label(m)).^2;
    end
    RMSE(SNR_loop)=sqrt(RMSE(SNR_loop))/5000;
end