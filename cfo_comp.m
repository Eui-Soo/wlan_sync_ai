function cfo_estimatied = cfo_comp(rx_data, fclk,pream,idx)

% rx_phs = zeros(1,length(pream));
% 
% for n=idx:length(rx_phs)+idx
%     rx_phs(n) = angle(rx_data(n+length(pream)/2+length(pream))*conj(rx_data(n+length(pream)/2)));
% end
% rx_av_phs = mean(rx_phs);
% cfo_estimatied = rx_av_phs/(2*pi*length(pream)/fclk);
rx_phs = 0;

for n=idx:160+idx
    rx_phs =rx_phs+(rx_data(n+length(pream)/2+length(pream))*conj(rx_data(n+length(pream)/2)));
end
rx_av_phs = angle(rx_phs);
cfo_estimatied = rx_av_phs/(2*pi*length(pream)/fclk);
