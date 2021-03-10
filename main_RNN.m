
% close all;
clear;

if ~exist('net_AWGN.mat','file')
% if 1
    
    load training_data_set_AWGN;
    
    YTrain = categorical(YTrain,[1 0],{'ON','OFF'});
    
    warning off parallel:gpu:device:DeviceLibsNeedsRecompiling
    try
        gpuArray.eye(2)^2;
    catch ME
    end
    try
        nnet.internal.cnngpu.reluForward(1);
    catch ME
    end
    
    layers = [ ...
        sequenceInputLayer(2*width) % observation frequency width x 2
        
        bilstmLayer(256,'OutputMode','last')
        fullyConnectedLayer(32)
        fullyConnectedLayer(2)
        softmaxLayer
        classificationLayer
        ];
    
    
    options = trainingOptions('sgdm', ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',0.9, ...
        'LearnRateDropPeriod',1, ...
        'InitialLearnRate',0.01, ...
        'shuffle','every-epoch', ...
        'MaxEpochs',50, ...
        'MiniBatchSize', 31*20, ...
        'plots','training-progress', ...
        'Verbose',false);
    
    net = trainNetwork(XTrain,YTrain,layers,options);
    clear XTrain YTrain;
    save net_AWGN net;
    load test_data_set_AWGN;
else
    load net_AWGN;
    load test_data_set_AWGN;
end


YTest = categorical(YTest,[1 0],{'ON','OFF'});

FDR = zeros(11,1); MDR = zeros(11,1); ACC = zeros(11,1);
total_ON_count = 0;
total_OFF_count = 0;
for loop=1:11
    %temp = predict(net,XTest(:,:,:,:,loop));
    temp = classify(net,XTest(:,loop));
    
    for n=1:length(temp)
        if YTest(n,loop) == 'ON'
            if temp(n) ~= YTest(n,loop)
                MDR(loop) = MDR(loop) + 1;
            end
            total_ON_count = total_ON_count + 1;
        else
            if temp(n) ~= YTest(n,loop)
                FDR(loop) = FDR(loop) + 1;
            end
            total_OFF_count = total_OFF_count + 1;
        end
    end
    MDR(loop) = MDR(loop)/total_ON_count;
    FDR(loop) = FDR(loop)/total_OFF_count;
    ACC(loop) = 1 - sum(temp~=YTest(:,loop))/length(temp);
end

SNR = -16:2:4;
figure(1); hold off;
semilogy(SNR,MDR,'bs-','LineWidth',1.5);
grid on;
% axis([-10 40 0. 2.5]);
xlabel('SNR (dB)'); ylabel('Miss Detection Probability');

figure(2); hold off;
semilogy(SNR,FDR,'bs-','LineWidth',1.5);
grid on;
% axis([-10 40 0. 2.5]);
xlabel('SNR (dB)'); ylabel('False Detection Probability');

figure(3); hold off;
plot(SNR,ACC,'bs-','LineWidth',1.5);
grid on;
% axis([-10 40 0. 2.5]);
xlabel('SNR (dB)'); ylabel('Total Accuracy');

figure(4); hold off;
semilogy(SNR,FDR,'bs-','LineWidth',1.5);
grid on;
hold on;
plot(SNR,MDR,'ro-','LineWidth',1.5);
xlabel('SNR (dB)'); ylabel('Probability');
legend('False Ratio','Miss Ratio');
% save performance_512FFT_64block MDR FDR ACC SNR






