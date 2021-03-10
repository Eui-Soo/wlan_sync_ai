clc
clear
close all

load data_train_set_cfo(24)_joint.mat
YTrain=zeros(100000,1);
for n=1:100000
    n
    [ttt,max_idx]=max(YTrain2(:,:,1,n));
    YTrain(n)=max_idx;
end
YTrain = categorical(YTrain,1:1024,string(1:1024));
layers = [ ...
    imageInputLayer([5 1024 1])
    %
    %     convolution2dLayer([7 1],16,'Padding','same')
    %     batchNormalizationLayer
    %     reluLayer
    % %     maxPooling2dLayer([1 2],'Stride',[1 2])
    % %
    convolution2dLayer([5 49],32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2])
    
    convolution2dLayer([5 49],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([1 2],'Stride',[1 2] )
    
    convolution2dLayer([5 49],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
        maxPooling2dLayer([1 2],'Stride',[1 2])
    
    convolution2dLayer([5 49],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
        maxPooling2dLayer([1 2],'Stride',[1 2])
    
    convolution2dLayer([5 49],512,'Padding','same')
    batchNormalizationLayer
    reluLayer
        maxPooling2dLayer([1 2],'Stride',[1 2])
%     fullyConnectedLayer(2048)
%     fullyConnectedLayer(512)
%     fullyConnectedLayer(1)
%     regressionLayer
    fullyConnectedLayer(1024)
    softmaxLayer
    classificationLayer
    ];
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'shuffle','every-epoch', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',5, ...
    'MiniBatchSize', 10, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain2,layers,options);
save net_paper_frame_joint_v1 net