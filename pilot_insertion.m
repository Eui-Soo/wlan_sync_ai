function y = pilot_insertion(x,N_fft)

if N_fft == 64
    L = length(x);
    frame = ceil(L/48); % unit of data = 48
    y = zeros(1, frame*52); % unit of data+pilot = 52
    
    for n = 1:frame
        temp = x(48*(n-1) +1 : 48*n);
        y(52*(n-1)+1:52*n) = [temp(1:5) 1 temp(6:18) 1 temp(19:30) 1 temp(31:43) 1 temp(44:48)];
    end
elseif N_fft==128
    L = length(x);
    frame = ceil(L/102); % unit of data = 48
    y = zeros(1, frame*108); % unit of data+pilot = 52
    
    for n = 1:frame
        temp = x(102*(n-1) +1 : 102*n);
        y(108*(n-1)+1:108*n) = [temp(1:9) 1 temp(10:22) 1 temp(23:49) 1 temp(50:53) 1 temp(54:79) 1 temp(80:92) 1 temp(93:102)];
    end  
    
end