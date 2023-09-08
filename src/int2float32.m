function x=int2float32(x)
% simple function to convert the stored 32bit integer to float point numbers
% get sign for 32 bit number 
x(x>2^31-1) = x(x>2^31-1) - 2^32;
% x(i)=x(i)*10^6*5/2^32;
x = x/100.0;
return
