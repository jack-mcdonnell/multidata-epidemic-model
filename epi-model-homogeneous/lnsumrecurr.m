function ls = lnsumrecurr(X)
% This function takes in a vector of logs and does the logsum of the
% unlogged values
% e.g. X = [x1, x2,..., xn], lnsumrecurr(log(X)) = log(sum(X))
    
    X = X(~isinf(X));       % -inf terms can be ignored
    X = sort(X);            % need X(i) <= X(i+1) for all X
    
    if isempty(X)
        ls = -inf;          % if sum(X)=0, log(sum(X))=-inf
    elseif length(X) == 1
        ls = X;
    elseif length(X) == 2
        ls = lnsum(X(2), X(1));
    else
        ls = lnsum(X(end), lnsumrecurr(X(1:end-1)));
    end

end


function r = lnsum(a,b)

x = a-b;
if x < 0
   x = -x; 
end

r = a + lfunc(x);

end


function r = lfunc(z)
% This function approximates log(z)

x = exp(-z);
y = 1+x;

r = log(y) - ((y-1)-x)/y;

end


