clc
clear
close all

load data_train_set_papaer_1d.mat

YTrain = categorical(YTrain,1:4096,string(1:4096));
layers = [ ...
    imageInputLayer([1 4096 1])

    convolution2dLayer([1 49],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2])
    convolution2dLayer([1 49],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2] )
    convolution2dLayer([1 49],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2])
    convolution2dLayer([1 49],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2])
    convolution2dLayer([1 49],512,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2])
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
    'MiniBatchSize', 100, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain,layers,options);
% save net_paper_1d_5layer_1_49 net