clc
clear
close all

load data_train_set_matlab_over.mat

YTrain = categorical(YTrain,1:4096,string(1:4096));
layers = [ ...
    imageInputLayer([64 64 1])
    convolution2dLayer([7 3],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)%32x32
    
    convolution2dLayer([7 3],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)%16x16
    
    convolution2dLayer([7 3],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)%8x8
    
    convolution2dLayer([7 3],512,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)%4x4
    
%     convolution2dLayer(4,1024,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer(2,'Stride',2)%2x2
%     convolution2dLayer([5 3],256,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     convolution2dLayer([5 3],512,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer(2,'Stride',2)%32x32
%     convolution2dLayer(7,256,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     convolution2dLayer(3,256,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     convolution2dLayer(3,128,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     convolution2dLayer(3,256,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer([2 1],'Stride',[2 1])%1x8
%     dropoutLayer(0.8)
%     fullyConnectedLayer(2048)
%     fullyConnectedLayer(4096)
%     fullyConnectedLayer(8192)
%     fullyConnectedLayer(512)
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
    'MaxEpochs',15, ...
    'MiniBatchSize', 200, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain,layers,options);
save net_frame4096_over_7x3_4L net