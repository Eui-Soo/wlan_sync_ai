clc
clear
close all
SNR=-18:4;
load('net_paper_cfo_only_v2.mat')
% BER_ai=zeros(1,length(SNR));
% BER_conven=zeros(1,length(SNR));
R_ai=zeros(1,length(SNR));
R_conven=zeros(1,length(SNR));
% err_idx=[];
% err_value=[];
cfo_range=-48:8:48;
for loop=1:length(SNR)
    loop
    S=sprintf('data_test_set_cfo(8)_SNR(%d)_matlab.mat',SNR(loop));
    load(S)
    Ypred=double(predict(net,XTest));
%     label_timing=YTest(1,1,1,:);
    label_cfo=YTest(1,1,2,:);
%     ai_timing=round(Ypred(:,1));
    ai_cfo=Ypred;
%     conven_count=0;
%     ai_count=0;
    RMSE_conven=0;
    RMSE_ai=0;
    for n=1:length(XTest)
        temp=XTest(:,:,1,n);
        [max_value,max_idx]=max(max(temp.'));
        [ttt,conven_timing]=max(temp(max_idx,:));
        RMSE_conven=RMSE_conven+(cfo_range(max_idx)-label_cfo(:,:,1,n))^2;
        RMSE_ai=RMSE_ai+(ai_cfo(n)-label_cfo(:,:,1,n))^2;
%         if label_timing(:,:,1,n)~=conven_timing
%            conven_count= conven_count+1;
%         end
%         if label_timing(:,:,1,n)~=ai_timing(n)
%             ai_count=ai_count+1;
%             err_idx=[err_idx n];
%             err_value=[err_value Ypred(n)];
%         end
    end
    R_conven(loop)=sqrt(RMSE_conven/length(XTest));
    R_ai(loop)=sqrt(RMSE_ai/length(XTest));
%     BER_conven(loop)=conven_count/length(XTest);
%     BER_ai(loop)=ai_count/length(XTest);
end
% semilogy(SNR,BER_ai,'bd-')
% hold on
% semilogy(SNR,BER_conven,'r*-')
% grid on
% % xticks(SNR)
% xlabel('SNR(dB)')
% ylabel('False Detection Probability')
% % title('1by49 5 layers 1D')
% legend('Proposed','Convention')
% axis([-18 0 1e-4 1])
figure(2)
plot(SNR,R_ai.*1e3,'bd-')
hold on
plot(SNR,R_conven.*1e3,'r*-')
xlabel('SNR(dB)')
ylabel('RMSE(Hz)')
% title('1by49 5 layers 1D')
legend('Proposed','Convention')
axis([-10 4 1500 10000])
grid on
% S=sprintf('cfo8_joint');
% save(S,'BER_ai','BER_conven','R_ai','R_conven')