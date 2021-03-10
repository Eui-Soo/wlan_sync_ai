function Symbols = QAM64MODU(bits_v)
   Symbols=(((2)*bits_v(:,1)-1).*( ((-2)*bits_v(:,2)+1).*((-2)*bits_v(:,3)+3)+4 )+1i*(((2)*bits_v(:,4)-1).*( ((-2)*bits_v(:,5)+1).*((-2)*bits_v(:,6)+3)+4 )))./sqrt(42);
  