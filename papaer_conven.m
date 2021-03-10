clc
clear
close all

%% para
N_bit=4800;
N_fft=64;
Rate=6;
fc = 2.4e6;   % [kHz] % Carrier Frequency
fclk = 20e3; % sampling frequency
maxppm =20;
N_set=10000;
L_window=400;
SNR=10;%13:20;
over_s=1;
%% PLCP preamble part
preamble = PLCP_preamble_gen(N_fft,over_s);
%% PLCP signal part
signal = PLCP_signal_gen(N_fft,Rate,over_s);
cfo_com=24;
cfo_range=-(fc*maxppm/1e6):cfo_com:(fc*maxppm/1e6);
RMSE_conven=zeros(1,length(SNR));
for SNR_loop=1:length(SNR)
    SNR_loop
    for loop=1:N_set
%         loop
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
                tmp=sum(register.*conj(rx_sig));
                corr(cfo_loop,n) = abs(tmp).^2;                
            end
        end
%         corr=corr/max(max(corr));
        cfo_buf=zeros(1,length(cfo_range));
        for cfo_loop2=1:length(cfo_range)
            cfo_buf(cfo_loop2)=max(corr(cfo_loop2,:));
        end
        S=sprintf('cfo = %0.2f',cfo);
        stem(cfo_range,cfo_buf)
        grid on
        xlabel('kHz')
%         title(S)
        [ttt,pred]=max(cfo_buf);
        RMSE_conven(SNR_loop)= RMSE_conven(SNR_loop)+(cfo_range(pred)-cfo)^2;
    end
    RMSE_conven(SNR_loop)=RMSE_conven(SNR_loop)/N_set;
end
save 'RMSE_v1.mat' 'RMSE_conven'