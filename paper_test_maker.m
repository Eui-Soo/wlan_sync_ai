clc
clear
close all

%% para
N_bit=48*20;
N_fft=64;
Rate=6;
% Rate = 6 Mbps < BPSK >
% Rate = 9 Mbps < BPSK >
% Rate = 12 Mbps < QPSK >
% Rate = 18 Mbps < QPSK >
% Rate = 24 Mbps < 16QAM >
% Rate = 36 Mbps < 16QAM >
% Rate = 48 Mbps < 64QAM >
% Rate = 54 Mbps < 64QAM >
fc = 5.3e6;   % [kHz] % Carrier Frequency
fclk = 20e3; % sampling frequency
maxppm =40;
N_set=5000;
L_window=1024;
cfo_com=11;
cfo_range=linspace(-(fc*maxppm/1e6),(fc*maxppm/1e6),cfo_com);
xx=linspace(cfo_range(1),cfo_range(end),cfo_range(end)*20+1);
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);

SNR=-10:5;
RMSE=zeros(size(SNR));
for SNR_loop=1:length(SNR)

    Test_data=zeros(length(cfo_range),L_window,N_set);
    Test_label=zeros(L_window,N_set);
    Test_cfo_label=zeros(1,N_set);
    Test_cfo_label2=zeros(length(xx),N_set);
    for loop=1:N_set
        %         loop
        %% Data part
        %% data
        %     SNR=-5+20*rand(1);
        label=randi([1 L_window-320],1,1);
        user_data = randi([0 1],1,N_bit);
        data = data_gen(user_data, N_fft, Rate);
        %% tx signal generation
        tx_data = [preamble signal data] ;
        rx_data=[zeros(1,160) zeros(1,label) tx_data];
        noise =sqrt(0.5*10^(-SNR(SNR_loop)/10))*(crandn(1,length(rx_data)));
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
        %     mesh(corr)
        [t,cfo_label]=min(abs(xx-cfo));
        Test_data(:,:,loop)=corr;
        Test_label(idx,loop)=1;
        Test_cfo_label(loop)=cfo;
        Test_cfo_label2(cfo_label,loop)=1;
        conven_cfo=cfo_comp(add_ppm, fclk,preamble(1:16),idx);
        tmp_rx=add_ppm(idx+160-32:end).*exp(-1j*2*pi*(conven_cfo/fclk).*[idx-length(preamble(161:224))/2:idx-length(preamble(161:224))/2+length(add_ppm(idx+160-32:end))-1]);
        conven_cfo2=cfo_comp(tmp_rx, fclk,preamble(161:224),1);
        cfo_est=conven_cfo+conven_cfo2;
        RMSE(SNR_loop)=RMSE(SNR_loop)+(cfo-cfo_est)^2;
    end
    RMSE(SNR_loop)=sqrt(RMSE(SNR_loop))/N_set;
%     S = sprintf('test_set_timing(%d)',SNR(SNR_loop));
%     save(S, 'Test_data','Test_label','-v7.3');
%     S1 = sprintf('test_set_cfo(%d)',SNR(SNR_loop));
%     save(S1, 'Test_data','Test_cfo_label','-v7.3');
S = sprintf('test_set(%d)',SNR(SNR_loop));
save(S, 'Test_data','-v7.3');
S1 = sprintf('test_set_timing_label(%d)',SNR(SNR_loop));
save(S1, 'Test_label','-v7.3');
S2 = sprintf('test_set_cfo_re_label(%d)',SNR(SNR_loop));
save(S2,'Test_cfo_label','-v7.3');
S3 = sprintf('test_set_cfo_cl_label(%d)',SNR(SNR_loop));
save(S3, 'Test_cfo_label2','-v7.3');
end
plot(SNR,RMSE,'linewidth',2)
grid on
xlabel('SNR(dB)')
ylabel('RMSE(kHz)')