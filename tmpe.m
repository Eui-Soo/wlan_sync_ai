clc
clear
close all
SNR=-5;
load('net_paper_1d_5layer_1_49.mat')

for loop=1:length(SNR)
    S=sprintf('data_test_set_papaer_1d(%d)_v2.mat',SNR(loop));
    load(S)
    Ypred=double(classify(net,XTest));
    conven_count=0;
    ai_count=0;
    
    for n=1:length(XTest)
        temp=XTest(:,:,1,n);
        [max_value,max_idx]=max(temp);
        if (YTest(n)~=max_idx)&&(Ypred(n)==YTest(n))
            S=sprintf("conventional=%d, proposed=%d, label=%d",max_idx,Ypred(n),YTest(n));
            figure(2)
            plot(temp)
            title(S)
        end
    end
end


