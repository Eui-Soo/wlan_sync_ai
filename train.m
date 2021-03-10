clc
clear
close all

load data_train_set_matlab_over_v2.mat

YTrain = categorical(YTrain,1:4096,string(1:4096));
layers = [ ...
    imageInputLayer([4096 1 1])
%     convolution2dLayer([9 1],16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer([2 1],'Stride',[2 1])
%     convolution2dLayer([9 1],32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer([2 1],'Stride',[2 1])
    convolution2dLayer([9 1],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([2 1],'Stride',[2 1])
    convolution2dLayer([9 1],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([2 1],'Stride',[2 1] )
    convolution2dLayer([9 1],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([2 1],'Stride',[2 1])
%     dropoutLayer(0.8)
%     convolution2dLayer([49 1],256,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer([2 1],'Stride',[2 1])    
%     dropoutLayer(0.9)
    fullyConnectedLayer(4096)
    softmaxLayer
    classificationLayer

    ];
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...    
    'shuffle','every-epoch', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',10, ...
    'MiniBatchSize', 10, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain,layers,options);
save net_frame4096_1d_v1 net