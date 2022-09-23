function encoded = encoder(msg, m, t)
    n = 2^m -1;
    k = m*t;
    [genpoly] = bchgenpoly(n,n-k);
    msg_padded = [msg zeros(1, k)];
    [~, remainder] = deconv(msg_padded, genpoly);
    encoded = msg_padded - remainder;
    encoded = [zeros(1,n+1-length(encoded)) encoded];
end