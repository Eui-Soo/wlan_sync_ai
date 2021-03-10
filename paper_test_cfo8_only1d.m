clc
clear
close all

%% para
N_bit=4800;
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

fc = 2.4e6;   % [kHz] % Carrier Frequency
fclk = 20e3; % sampling frequency
maxppm =20;
N_set=10000;
L_window=400;
SNR=-12:20;
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
% stem(preamble,'b')
% grid on
% xlabel('time')
% axis([0 160*over_s -0.6 0.6])
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);
cfo_com=24;
cfo_range=-(fc*maxppm/1e6):cfo_com:(fc*maxppm/1e6);

for SNR_loop=1:length(SNR)
    XTest = zeros(length(cfo_range),1,1,N_set);
    YTest = zeros(1,1,1,N_set);
    for loop=1:N_set
        %% Data part
        %% data
        %     SNR=-20+30*rand(1);
        label=randi([1 160],1,1);
        user_data = randi([0 1],1,N_bit);
        data = data_gen(user_data, N_fft, Rate);
        %% tx signal generation
        tx_data = [preamble signal data] ;
        %     if label>0
        %         rx_data=[tx_data(label+1:end)];
        %     elseif label==0
        rx_data=[zeros(1,label) tx_data];
        %     else
        %         rx_data=[zeros(1,-label) tx_data];
        %     end
        noise =sqrt(0.5*10^(-SNR(SNR_loop)/10))*(crandn(1,length(rx_data)));
        rx_data=rx_data+noise;
        ppm = maxppm*(rand(1)-0.5)*2;    % random ppm gen [ -1 ~ 1]
        cfo = fc * ppm/1e6;   % [tolerence]
        
        add_ppm = rx_data.*exp(1j*2*pi*(cfo/fclk)*[1:length(rx_data)]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% receiver side %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rx_sig = preamble(length(preamble)/2:end);   % preamble to synchronize
        %     L_corr = length(rx_sig);    % correlation length
        %     mean_pwr = mean(abs(rx_sig(1:L_corr)).^2);
        corr = zeros(length(cfo_range),L_window);
        register=zeros(1,length(rx_sig));
        for cfo_loop=1:length(cfo_range)
            temp=add_ppm.*exp(-1j*2*pi*(cfo_range(cfo_loop)/fclk)*[1:length(add_ppm)]);
            for n = 1:L_window
                register=circshift(register,-1);
                register(end)=temp(n+label);
                %         tmp1=sum(real(rx_sig).*real(register));
                %         tmp2=sum(imag(rx_sig).*imag(register));
                %         tmp=tmp1+tmp2;
                tmp=sum(register.*conj(rx_sig));
                corr(cfo_loop,n) = abs(tmp).^2;
                
            end
        end
        corr=corr/max(max(corr));
        cfo_buf=zeros(1,length(cfo_range));
        for cfo_loop2=1:length(cfo_range)
            cfo_buf(cfo_loop2)=max(corr(cfo_loop2,:));
        end
        %     idx=320-label;
        %     figure(1)
        % %     stem(cfo_range,cfo_buf)
        %     mesh(corr)
        % %     plot(corr)
        %     S=sprintf('label=%d, SNR=%.2f, CFO=%.2f',320-label,SNR,cfo/1e3);
        %     grid on;
        %     axis([0 1000 0 max(corr)+1000])
        %     figure(2)
        %     plot(abs(rx_data))
        %     grid on;
        %     axis([0 2000 0 max(abs(rx_data))+1])
        %         title(S);
        %     [max_value,I]=max(corr);
        %     corr=corr/max_value;
        
        
        
        %     corr2=reshape(corr,16,L_window/16);
        %     %     figure(3)
        %     %      imshow(corr)
        XTest(:,:,1,loop) = cfo_buf;
        YTest(1,1,1,loop)=cfo;
        %         YTrain(1,1,2,loop)=cfo;
        %     XTrain2(:,:,1,loop) = corr2;
        %     YTrain2(1,loop)=idx;
    end
    S = sprintf('data_test_set_cfo(%d)_only_SNR(%d)',cfo_com,SNR(SNR_loop));
    save(S, 'XTest','YTest','-v7.3');
end