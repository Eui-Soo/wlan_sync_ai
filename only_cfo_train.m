clc
clear

clc
clear
close all

load train_set.mat
load train_set_cfo_re_label.mat
XTrain=zeros(11,1024,1,50000);
for n=1:50000
   XTrain(:,:,1,n)=Train_data(:,:,n); 
end
YTrain=reshape(Train_cfo_label,1,1,1,50000);
% YTrain = categorical(YTrain,1:4096,string(1:4096));
layers = [ ...
    imageInputLayer([11 1024 1])
    
    convolution2dLayer([11 1],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 8],'Stride',[1 8])
    
    convolution2dLayer([11 1],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 8],'Stride',[1 8])
    
    convolution2dLayer([11 1],512,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 8],'Stride',[1 8])
%     fullyConnectedLayer(2048)
%     fullyConnectedLayer(512)
    fullyConnectedLayer(1)
    regressionLayer
    ];
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'shuffle','every-epoch', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',5, ...
    'MiniBatchSize', 50, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain,layers,options);
save net_cfo_only net