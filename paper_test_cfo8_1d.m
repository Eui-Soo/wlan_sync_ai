clc
clear
% close all
SNR=-12:20;
load('net_paper_cfo_only_v11.mat')
R_ai=zeros(1,length(SNR));
R_conven=zeros(1,length(SNR));
cfo_com=8;
cfo_range=-48:cfo_com:48;
cfo_s=-48:.001:48;
for loop=1:length(SNR)
    loop
    S=sprintf('data_test_set_cfo(%d)_only_SNR(%d).mat',cfo_com,SNR(loop));
    load(S)
    Ypred=double(predict(net,XTest));
    label_cfo=YTest(1,1,1,:);
    ai_cfo=Ypred;

    RMSE_conven=0;
    RMSE_ai=0;
    for n=1:length(XTest)
        temp=XTest(:,:,1,n);        
        yy=spline(cfo_range,temp,cfo_s);
        [m_v,m_i]=max(yy);
%         [max_value,max_idx]=max(max(temp.'));
        RMSE_conven=RMSE_conven+(cfo_s(m_i)-label_cfo(:,1,1,n))^2;
        RMSE_ai=RMSE_ai+(ai_cfo(n)-label_cfo(:,:,1,n))^2;
    end
    R_conven(loop)=sqrt(RMSE_conven/length(XTest));
    R_ai(loop)=sqrt(RMSE_ai/length(XTest));
end
% figure(2)
hold on
plot(SNR,R_ai.*1e3,'bd-')
hold on
plot(SNR,R_conven.*1e3,'r*-')
xlabel('SNR(dB)')
ylabel('RMSE(Hz)')
% title('1by49 5 layers 1D')
legend('Proposed','Conventional')
% axis([-10 20 0 10000])
grid on
% S=sprintf('cfo8_joint');
% save(S,'BER_ai','BER_conven','R_ai','R_conven')