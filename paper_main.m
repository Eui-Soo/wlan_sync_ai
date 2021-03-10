clc
clear
close all

%% para
N_bit=48*20;
N_fft=128;
Rate=6;
% Rate = 6 Mbps < BPSK >
% Rate = 9 Mbps < BPSK >
% Rate = 12 Mbps < QPSK >
% Rate = 18 Mbps < QPSK >
% Rate = 24 Mbps < 16QAM >
% Rate = 36 Mbps < 16QAM >
% Rate = 48 Mbps < 64QAM >
% Rate = 54 Mbps < 64QAM >
fc =5.3e6;   % [kHz] % Carrier Frequency
fclk = 40e3; % sampling frequency
maxppm =40;
N_set=50000;
L_window=1024;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);


Train_data=zeros(length(cfo_range),L_window,N_set);
Train_label=zeros(L_window,N_set);
Train_cfo_label=zeros(1,N_set);
Train_cfo_label2=zeros(length(xx),N_set);
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);
RMSE=0;
for loop=1:N_set
%         loop
    %% Data part
    %% data
    SNR=-5;%-5+15*rand(1);
    label=randi([1 L_window-320],1,1);
    user_data = randi([0 1],1,N_bit);
    data = data_gen(user_data, N_fft, Rate);
    %% tx signal generation
    tx_data = [preamble signal data] ;
    rx_data=[zeros(1,160) zeros(1,label) tx_data];
    noise =sqrt(0.5*10^(-SNR/10))*(crandn(1,length(rx_data)));
    rx_data=rx_data+noise;    
    ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
    cfo = fc * ppm/1e6;   % [tolerence]    
    add_ppm = rx_data.*exp(1j*2*pi*(cfo/fclk)*[1:length(rx_data)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% receiver side %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rx_sig = preamble(1:length(preamble)/2);   % preamble to synchronize
    corr = zeros(1,L_window);
    register=zeros(1,length(rx_sig));
    for cfo_loop=1:length(cfo_range)
        temp=add_ppm.*exp(-1j*2*pi*(cfo_range(cfo_loop)/fclk)*[1:length(add_ppm)]);
        for n = 1:L_window            
            rx_tmp=circshift(temp,-n);
            register=rx_tmp(1:length(rx_sig));
            %         register(end)=temp(n);
            tmp=sum(register.*conj(rx_sig));
            corr(cfo_loop,n) = abs(tmp).^2;
        end
    end
    corr=corr/max(max(corr));
    idx=160+label;
    
    [t,cfo_label]=min(abs(xx-cfo));
    
%     xlabel('sample index, n')
%     ylabel('fo')
%     imshow(corr)
    Train_data(:,:,loop)=corr;
    Train_label(idx,loop)=1;
    Train_cfo_label(loop)=cfo;
    Train_cfo_label2(cfo_label,loop)=1;
    conven_cfo=cfo_comp(add_ppm, fclk,preamble(1:16),idx);
    tmp_rx=add_ppm(idx+160-32:end).*exp(-1j*2*pi*(conven_cfo/fclk).*[idx-length(preamble(161:224))/2:idx-length(preamble(161:224))/2+length(add_ppm(idx+160-32:end))-1]);
    conven_cfo2=cfo_comp(tmp_rx, fclk,preamble(161:224),1);
    cfo_est=conven_cfo+conven_cfo2;
%     
    y=spline(cfo_range,corr(:,idx),xx);
    [tt,ttt]=max(y);
%     [t,spl_est]=min(abs(xx-max(y)));
    hold off
%     mesh(1:1024,cfo_range,corr)
    plot(xx,y);
    hold on
    stem(cfo_range,corr(:,idx));
    hold on
    plot(xx(ttt),tt,'*')
    hold on
    plot(xx(cfo_label),max(Train_cfo_label2(:,loop)),'r^')
%     [A,B]=max(spl);
    S=sprintf("CFO: %f, est: %f, conven: %f",cfo, xx(ttt), cfo_est);
    title(S)
%     RMSE=RMSE+(cfo-cfo_est)^2;
    figure(3)
    hold off;
    mesh(corr)
    view(360,0)
end
% RMSE=sqrt(RMSE)/N_set;
S = sprintf('train_set');
save(S, 'Train_data','-v7.3');
S1 = sprintf('train_set_timing_label');
save(S1, 'Train_label','-v7.3');
S2 = sprintf('train_set_cfo_re_label');
save(S2,'Train_cfo_label','-v7.3');
S3 = sprintf('train_set_cfo_cl_label');
save(S3, 'Train_cfo_label2','-v7.3');