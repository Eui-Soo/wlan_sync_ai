SNR=-12:20;
load('net_paper_frame_joint_v1.mat')
FER_ai=zeros(1,length(SNR));
FER_conven=zeros(1,length(SNR));
cfo_com=24;
for loop=1:length(SNR)
    loop
    S=sprintf('data_test_set_cfo(%d)_joint_SNR(%d).mat',cfo_com,SNR(loop));
    load(S)
    Ypred=double(predict(net,XTest));
    label_cfo=YTest(1,1,1,:);
    ai_cfo=Ypred;

    RMSE_conven=0;
    RMSE_ai=0;
    for n=1:length(XTest)
        temp=XTest(:,:,1,n);
        [max_value,max_idx]=max(max(temp.'));
        RMSE_conven=RMSE_conven+(cfo_range(max_idx)-label_cfo(:,1,1,n))^2;
        RMSE_ai=RMSE_ai+(ai_cfo(n)-label_cfo(:,:,1,n))^2;
    end
    FER_conven(loop)=sqrt(RMSE_conven/length(XTest));
    FER_ai(loop)=sqrt(RMSE_ai/length(XTest));
end
% figure(2)
hold on
plot(SNR,FER_ai.*1e3,'md-')
hold on
plot(SNR,FER_conven.*1e3,'r*-')
xlabel('SNR(dB)')
ylabel('RMSE(Hz)')
% title('1by49 5 layers 1D')
legend('Proposed','Conventional')
% axis([-10 20 0 10000])
grid on
% S=sprintf('cfo8_joint');
% save(S,'BER_ai','BER_conven','R_ai','R_conven')