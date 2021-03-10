clc
clear
SNR=1;
for nn=1:length(SNR)
S=sprintf('train_set_cfo_re_label.mat');
load(S)
fc =5.3e6;   % [kHz] % Carrier Frequency
fclk = 40e3; % sampling frequency
maxppm =40;
N_set=50000;
L_window=1024;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*200+1);
Train_cfo_label2=zeros(length(xx),N_set);
for n=1:50000
    [tmp,label]=min(abs(xx-Train_cfo_label(n)));
    Train_cfo_label2(label,n)=1;
end
S3 = sprintf('train_set_cfo_label_class.mat');
save(S3, 'Train_cfo_label2','-v7.3');
% clear Test_cfo_label2
% clear Test_cfo_label
end