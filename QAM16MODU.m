function Symbols = QAM16MODU(bits_v)
   Symbols=(((bits_v(:,1)*(2)-1).*(3-bits_v(:,2)*(2)))+1i*((bits_v(:,3)*(2)-1).*(3-bits_v(:,4)*(2))))./sqrt(10);
