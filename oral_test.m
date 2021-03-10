clc
clear
close all

load corr_oral
M=ans;
for n=1:20
    fig=figure(n);
    set(fig,'Position',[100 100 400 300]);
    plot(M(1:125+32*n))
    axis([0 864 min(M) max(M)])
    xticks([])
    yticks([])
end
% epoch=0:10;
% loss=[2.1 0.2705 0.0291 0.0209 0.0144 0.0120 0.0083 0.0072 0.0052 0.0048 0.0058];
% acc=[0.2 0.9378 0.9922 0.9944 0.9960 0.9968 0.9976 0.9979 0.9986 0.9987 0.9987];
% epoch_x=0:0.05:10;
% loss_x=spline(epoch,loss,epoch_x);
% plot(epoch_x,loss_x,'linewidth',2)
% grid on
% xlabel('Epoch')
% ylabel('Loss')
% acc_x=spline(epoch,acc,epoch_x);
% plot(epoch_x,acc_x,'r','linewidth',2)
% grid on
% xlabel('Epoch')
% ylabel('Accuracy')
% axis([0 10 0 1.1])

% epoch=0:10:100;
% loss=[80 52 12 4.5 3.2 2.8 2.5 2.3 2.1 1.95 1.7265];
% % acc=[0.2 0.9378 0.9922 0.9944 0.9960 0.9968 0.9976 0.9979 0.9986 0.9987 0.9987];
% epoch_x=0:0.05:100;
% loss_x=spline(epoch,loss,epoch_x);
% plot(epoch_x,loss_x,'linewidth',2)
% grid on
% xlabel('Epoch')
% ylabel('Loss')
% % acc_x=spline(epoch,acc,epoch_x);
% figure
% plot(epoch_x,loss_x,'r','linewidth',2)
% grid on
% xlabel('Epoch')
% ylabel('Mean square error')
% axis([0 100 0 82])