clc
clear
load train_set_cfo_tmp.mat

fc =5.3e6;   % [kHz] % Carrier Frequency
fclk = 40e3; % sampling frequency
maxppm =40;
N_set=200;
L_window=1024;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*200+1);


Train_cfo_label2=zeros(length(xx),length(Train_cfo_label));

for n=1:length(Train_cfo_label)
    [a,b]=min(abs(Train_cfo_label(n)-xx));
    Train_cfo_label2(b,n)=1;
    plot(xx,Train_cfo_label2(:,n))
end