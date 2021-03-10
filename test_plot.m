clc
clear
close all

load wlan_test_set_joint_SNR(18).mat
a=Test_data(1,:,:,1809);
b=squeeze(a);
imshow(b)