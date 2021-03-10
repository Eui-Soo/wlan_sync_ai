clc
clear
close all
SNR=-18:4;
load('net_paper_1d_5layer_1_49.mat')
BER_ai=zeros(1,length(SNR));
BER_conven=zeros(1,length(SNR));
R_ai=zeros(1,length(SNR));
R_conven=zeros(1,length(SNR));
err_idx=[];
err_value=[];
for loop=1:length(SNR)
    loop
    S=sprintf('data_test_set_cfo(8)_SNR(%d).mat',SNR(loop));
    load(S)
    Ypred=double(classify(net,XTest));
    conven_count=0;
    ai_count=0;
    RMSE_conven=0;
    RMSE_ai=0;
    for n=1:length(XTest)
        temp=XTest(:,:,1,n);
        [max_value,max_idx]=max(temp);
        RMSE_conven=RMSE_conven+(max_idx-YTest(n))^2;
        RMSE_ai=RMSE_ai+(Ypred(n)-YTest(n))^2;
        if YTest(n)~=max_idx
           conven_count= conven_count+1;
        end
        if Ypred(n)~=YTest(n)
            ai_count=ai_count+1;
            err_idx=[err_idx n];
            err_value=[err_value Ypred(n)];
        end
    end
    R_conven(loop)=sqrt(RMSE_conven/length(XTest));
    R_ai(loop)=sqrt(RMSE_ai/length(XTest));
    BER_conven(loop)=conven_count/length(XTest);
    BER_ai(loop)=ai_count/length(XTest);
end
semilogy(SNR,BER_ai,'bd-')
hold on
semilogy(SNR,BER_conven,'r*-')
grid on
% xticks(SNR)
xlabel('SNR(dB)')
ylabel('False Detection Probability')
% title('1by49 5 layers 1D')
legend('Proposed','Convention')
axis([-18 0 1e-4 1])
figure(2)
plot(SNR,R_ai,'bd-')
hold on
plot(SNR,R_conven,'r*-')
xlabel('SNR(dB)')
ylabel('RMSE(sample)')
% title('1by49 5 layers 1D')
legend('Proposed','Convention')
axis([-8 2 0 10])
grid on