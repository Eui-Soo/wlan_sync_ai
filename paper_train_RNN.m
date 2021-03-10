clc
clear
close all

load data_train_set_cfo(8)_RNN.mat
% YTrain=YTrain(:,:,2,:);
% YTrain = categorical(YTrain,1:4096,string(1:4096));
layers = [
    sequenceInputLayer(400)    
    bilstmLayer(128,'OutputMode','last')
    lstmLayer(256)
    lstmLayer(512)
%     fullyConnectedLayer(512)
    fullyConnectedLayer(2)
    regressionLayer
    ];
options = trainingOptions('adam', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateDropPeriod',1, ...
    'InitialLearnRate',0.01, ...
    'shuffle','every-epoch', ...
    'MaxEpochs',50, ...
    'MiniBatchSize', 2000, ...
    'plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(XTrain,YTrain,layers,options);
save net_paper_cfo8_RNN net