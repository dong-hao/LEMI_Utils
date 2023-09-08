function x=int2float24(x)
% simple function to convert the stored 24bit integer to float point numbers
% get sign for 24 bit number 
x(x>2^23-1) = x(x>2^23-1) - 2^24;
% x(i)=x(i)*10^6*5/2^23;
x = x/100.0;
return
