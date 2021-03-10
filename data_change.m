clc
clear
close all
SNR=-10:5;
for SNR_loop=1:length(SNR)
    S=sprintf('test_set(%d).mat',SNR(SNR_loop));
    load(S)
%     load train_set
    Test_data_timing=zeros(1,1024,5000);
    Test_data_cfo=zeros(1,11,5000);
    for n=1:5000
        tmp=Test_data(:,:,n);
        [a,timing_idx]=max(max(tmp.'));
        Test_data_timing(:,:,n)=tmp(timing_idx,:);
        for nn=1:11
            Test_data_cfo(1,nn,n)=max(tmp(nn,:));
        end
    end
    S1=sprintf('test_set_timing(%d).mat',SNR(SNR_loop));
    S2=sprintf('test_set_cfo(%d).mat',SNR(SNR_loop));
    save(S1, 'Test_data_timing','-v7.3');
    save(S2, 'Test_data_cfo','-v7.3');
end
