% Add leading zeros
function xpad = pad(x,k)
    len = length(x);
    if (len<k)
        xpad = [zeros(1, k-len) x];
    end
end