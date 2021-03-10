function y=conv_fec(x,Rate)
K = 7;
treillis = poly2trellis(K, [133 171]);
if Rate == 6
    y = convenc(x, treillis,[],[]);
elseif Rate == 9
    puncpat = [ 1 1 0 1 1 0 ];
    y = convenc(x, treillis, puncpat,[]);
elseif Rate == 12
    y = convenc(x, treillis,[],[]);
elseif Rate == 18
    puncpat = [ 1 1 0 1 1 0 ];
    y = convenc(x, treillis,puncpat,[]);
elseif Rate == 24
    y = convenc(x, treillis,[],[]);
elseif Rate == 36
    puncpat = [ 1 1 0 1 1 0 ];
    y = convenc(x, treillis,puncpat,[]);
elseif Rate == 48
    puncpat = [ 1 1 0 1];
    y = convenc(x, treillis,puncpat,[]);
elseif Rate == 54
    puncpat = [ 1 1 0 1 1 0 ];
    y = convenc(x, treillis,puncpat,[]);
end