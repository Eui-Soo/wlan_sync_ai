function y=mapping(data,Rate)
if Rate==6 || Rate==9
    y=BPSKMODU(data);
elseif Rate==12 || Rate==18
    y=QPSKMODU(data);
elseif Rate==24 || Rate==36
    y=QAM16MODU(data);
elseif Rate==48 || Rate == 54
    y=QAM64MODU(data);
end