clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Design Parameters

Fs = 32; % sampling clock in MHz
Fbaud = 0.8; % symbol rate in MHz
% 참고: Fs/Fbaud는 정수가 되어야 함
over_s = Fs/Fbaud;
roll_off = 0.2; % roll-off factor  (0~1)
ch_space = 1; % channel space in MHz

% definition for observation length
N_fft = 512;
L_overlap = N_fft/2;
N_time_block = 64;

% Parameters for Training, Test set
N_training = 2000;
N_test = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


L_time_total = (N_fft-L_overlap)*(N_time_block-1)+N_fft;
N_sym = ceil(L_time_total/over_s)+1;

% definition of modulation
tx_obj = comm.QPSKModulator('BitInput',1);
N_bit = 2*N_sym;

Fc_table = -Fs/2+ch_space:ch_space:+Fs/2-ch_space;
Fc_table = round(Fc_table);
Fc_table = Fc_table + max(Fc_table);

width = round(N_fft/(Fs/ch_space));
N_ch = length(Fc_table);


if ~exist('training_data_set_AWGN.mat','file')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Training data set generation
    
    XTrain = zeros(2*width,N_time_block,1,N_training*N_ch);
    YTrain = zeros(N_training*N_ch,1);
    
    for loop=1:N_training
        
        SNR = rand(1)*70-20;
        
        ch_status = randi([0 1],length(Fc_table),1);
        YTrain(N_ch*(loop-1)+1:N_ch*loop) = ch_status;
        
        
        psf = rcosdesign(roll_off, 16, over_s, 'normal');
        psf = psf/sum(psf);
        
        % rx signal generation
        clear tx_sig;
        for n=1:length(Fc_table)
            if ch_status(n) == 1
                % 1 channel signal generation
                tx_sym = step(tx_obj,randi([0 1],N_bit,1));
                temp = upfirdn(tx_sym,psf,over_s,1)*sqrt(over_s);
                if exist('tx_sig','var')
                    temp1 = temp((length(psf)+1)/2:end);
                    tx_sig = tx_sig + temp1.*exp(1j*2*pi*Fc_table(n)/Fs*[1:length(temp1)]');
                else
                    temp1 = temp((length(psf)+1)/2:end);
                    tx_sig = temp1.*exp(1j*2*pi*Fc_table(n)/Fs*[1:length(temp1)]');
                end
            end
        end
        % noise generation
        if exist('tx_sig','var')
            noise = sqrt(0.5)*crandn(size(tx_sig));
        else
            noise = sqrt(0.5)*crandn(L_time_total,1);
        end
        % rx signal + noise
        rx_sig = sqrt(10^(SNR/10))*tx_sig + noise;
        
        % rx signal scalining
        rx_sig = rx_sig/300;
        
        % rx signal vector to matrix
        rx_sig_mat = zeros(N_fft,N_time_block);
        idx = 1;
        for n=1:N_time_block
            temp = rx_sig(idx:idx+N_fft-1).*hanning(N_fft);
            temp = abs(fft(temp,N_fft)/sqrt(N_fft));
            temp = wshift('1D',temp,-round(N_fft/(Fs/ch_space)/2));
            rx_sig_mat(:,n) = temp/max(temp);
            %         rx_sig_mat(:,n) = temp;
            idx = idx + N_fft - L_overlap;
        end
        
        for n=1:N_ch
            XTrain(:,:,1,(loop-1)*N_ch+n) = [rx_sig_mat(width*(n-1)+1:width*n,:); rx_sig_mat(end-width+1:end,:)];
        end
        
        %     figure(1); hold off;
        %     imshow(rx_sig_mat); disp(ch_status');
        %     figure(2); hold off;
        %     imshow(rx_sig_mat(width+1:width*2,:));
        
        if mod(loop,1000) == 0
            disp(loop);
        end
        
    end
    rand_idx = randperm(N_training*N_ch);
    XTrain_matrix = XTrain(:,:,1,rand_idx); % matrix, used for CNN
    XTrain = cell(length(XTrain_matrix(1,1,1,:)),1); % cell, used for RNN
    for n=1:length(XTrain_matrix(1,1,1,:))
        XTrain{n} = XTrain_matrix(:,:,1,n);
    end
    YTrain = YTrain(rand_idx);
    
    
    
    im_h = width*2;
    im_w = N_time_block;
    
    save training_data_set_AWGN XTrain YTrain im_h im_w width -v7.3
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end


if 1 %~exist('test_data_set_AWGN.mat','file')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Test data set generation
    
    SNR_table = [-16:2:4];
    XTest_matrix = zeros(2*width,N_time_block,1,N_test*N_ch,length(SNR_table)); % matrix, used for CNN
    XTest = cell(N_test*N_ch,length(SNR_table)); % cell, used for RNN
    YTest = zeros(N_test*N_ch,length(SNR_table));
    for SNR_loop=1:length(SNR_table)
        
        SNR = SNR_table(SNR_loop);
        
        for loop=1:N_test
            
            ch_status = randi([0 1],length(Fc_table),1);
            YTest(N_ch*(loop-1)+1:N_ch*loop,SNR_loop) = ch_status;
            
            psf = rcosdesign(roll_off, 16, over_s, 'normal');
            psf = psf/sum(psf);
            
            % rx signal generation
            clear tx_sig;
            for n=1:length(Fc_table)
                if ch_status(n) == 1
                    % 1 channel signal generation
                    tx_sym = step(tx_obj,randi([0 1],N_bit,1));
                    temp = upfirdn(tx_sym,psf,over_s,1)*sqrt(over_s);
                    if exist('tx_sig','var')
                        temp1 = temp((length(psf)+1)/2:end);
                        tx_sig = tx_sig + temp1.*exp(1j*2*pi*Fc_table(n)/Fs*[1:length(temp1)]');
                    else
                        temp1 = temp((length(psf)+1)/2:end);
                        tx_sig = temp1.*exp(1j*2*pi*Fc_table(n)/Fs*[1:length(temp1)]');
                    end
                end
            end
            % noise generation
            if exist('tx_sig','var')
                noise = sqrt(0.5)*crandn(size(tx_sig));
            else
                noise = sqrt(0.5)*crandn(L_time_total,1);
            end
            % rx signal + noise
            rx_sig = sqrt(10^(SNR/10))*tx_sig + noise;
            
            % rx signal scalining
            rx_sig = rx_sig/300;
            
            
            % rx signal vector to matrix
            rx_sig_mat = zeros(N_fft,N_time_block);
            idx = 1;
            for n=1:N_time_block
                temp = rx_sig(idx:idx+N_fft-1).*hanning(N_fft);
                temp = abs(fft(temp,N_fft)/sqrt(N_fft));
                temp = wshift('1D',temp,-round(N_fft/(Fs/ch_space)/2));
                rx_sig_mat(:,n) = temp/max(temp);
                % rx_sig_mat(:,n) = temp;
                idx = idx + N_fft - L_overlap;
            end
            % Input signal matrix generation for CNN
            for n=1:N_ch
                XTest_matrix(:,:,1,(loop-1)*N_ch+n,SNR_loop) = [rx_sig_mat(width*(n-1)+1:width*n,:); rx_sig_mat(end-width+1:end,:)];
            end
            % Input signal cell generation for RNN
            for n=1:length(XTest_matrix(1,1,1,:,1))
                XTest{n,SNR_loop} = XTest_matrix(:,:,1,n,SNR_loop);
            end
            
            %         figure(1); hold off;
            %         imshow(rx_sig_mat); disp(ch_status');
            
            if mod(loop,1000) == 0
                disp(loop);
            end
        end
        
    end
    
    save test_data_set_AWGN XTest YTest width -v7.3
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end