clc
clear
close all

SNR=-15:3:20;
timing_range=160;
N_set=10000;

for loop=1:length(SNR)
    loop    
    S=sprintf('wlan_test_set_joint_SNR(%d).mat',SNR(loop));
    load(S)
    S1=sprintf('wlan_test_set_timing_SNR(%d).mat',SNR(loop));
    load(S1)
    Test_timing_label_onehot=zeros(timing_range,N_set);
    for iter=1:N_set
        Test_timing_label_onehot(Test_timing_label_idx(iter)+1,iter)=1;        
    end
    S=sprintf("wlan_test_set_joint_SNR(%d)_v2",SNR(loop));
    save(S,'Test_data','Test_cfo_label','Test_timing_label_onehot','Test_timing_label_idx','-v7.3')
    S1=sprintf("wlan_test_set_timing_SNR(%d)_v2",SNR(loop));
    save(S1,'Test_data_timing','Test_timing_label_onehot','Test_timing_label_idx','-v7.3')
end


