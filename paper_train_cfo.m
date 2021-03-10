clc
clear
close all

load wlan_train_set_joint.mat
XTrain=zeros(11,800,1,100000);
for n=1:100000
    for nn=1:800
        tmp=Train_data(1,nn,:,n);
        XTrain(:,nn,1,n)=tmp;
    end
end
YTrain = Train_cfo_label.'/1e3;
lgraph = layerGraph();
tempLayers = [
    imageInputLayer([11 800 1],"Name","imageinput")
    convolution2dLayer([11 1],32,"Name","conv_1","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([1 4],"Name","maxpool_1","Padding","same","Stride",[1 4])];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([11 1],64,"Name","conv_2","Padding","same")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([1 4],"Name","maxpool_2","Padding","same","Stride",[1 4])
    convolution2dLayer([11 1],128,"Name","conv_4","Padding","same")
    batchNormalizationLayer("Name","batchnorm_3")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = convolution2dLayer([1 1],128,"Name","conv_3","Padding","same","Stride",[1 4]);
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    additionLayer(2,"Name","addition_1")
    reluLayer("Name","relu_3")
    maxPooling2dLayer([1 4],"Name","maxpool_3","Padding","same","Stride",[1 4])];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([11 1],256,"Name","conv_5","Padding","same")
    batchNormalizationLayer("Name","batchnorm_4")
    reluLayer("Name","relu_4")
    maxPooling2dLayer([1 4],"Name","maxpool_4","Padding","same","Stride",[1 4])
    convolution2dLayer([11 1],512,"Name","conv_7","Padding","same")
    batchNormalizationLayer("Name","batchnorm_5")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = convolution2dLayer([1 1],512,"Name","conv_6","Padding","same","Stride",[1 4]);
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    additionLayer(2,"Name","addition_2")
    reluLayer("Name","relu_5")
    maxPooling2dLayer([1 4],"Name","maxpool_5","Padding","same","Stride",[1 4])
    fullyConnectedLayer(1,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

% 헬퍼 변수 정리
clear tempLayers;

lgraph = connectLayers(lgraph,"maxpool_1","conv_2");
lgraph = connectLayers(lgraph,"maxpool_1","conv_3");
lgraph = connectLayers(lgraph,"batchnorm_3","addition_1/in1");
lgraph = connectLayers(lgraph,"conv_3","addition_1/in2");
lgraph = connectLayers(lgraph,"maxpool_3","conv_5");
lgraph = connectLayers(lgraph,"maxpool_3","conv_6");
lgraph = connectLayers(lgraph,"conv_6","addition_2/in2");
lgraph = connectLayers(lgraph,"batchnorm_5","addition_2/in1");
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'shuffle','every-epoch', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',10, ...
    'MiniBatchSize', 200, ...
    'plots','training-progress', ...
    'Verbose',false);
net = trainNetwork(XTrain,YTrain,lgraph,options);
% save net_paper_cfo_only_skip_network_v1 net