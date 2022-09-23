function decoded = decoder(codeArr, encoded, m, t)
    prim_poly = 67;
    n = 2^m -1;
    k = m*t;
   max_errors = 4;% floor((k)/2);
    %[1 0 1 1 0 0 1 1]
    %orignal----------------[1 0 1 1 0 0 1 1 0 1 0 1 0 1 0 1 1 1 0 0 0 1 0 0 0 1 1 0 1 0 0 0]
    codev = [zeros(1,n-(length(codeArr))) codeArr];
    reccode=gf(codev(2:64), m);
    orig_vals = reccode.x;
    errors = zeros(1, n);
    g = [];
    S = [];

    t = 4; m = 6;
    alpha = gf(2, m);
    %creating alpha array
    %note that syndrome should be in the order [s3, s2, s1, s0]

    alpha_tb=gf(zeros(1, 2*t), m);
    for i=1:2*t
        %alpha_tb(i)=alpha^(2*t-i+1); %   2    4    8   16   32    3    6   12
        alpha_tb(i)=alpha^(i);
    end
    %syndrome generation
    syn=gf(zeros(1, 2*t), m);
    q = [zeros(1,n-length(reccode)) reccode];
    for i=1:n% org  i = 1 : n+1
        syn=syn.*alpha_tb+q(i);
    end
    syndrome = trim(syn);
    %{
    % Find the syndromes (Check if dividing the message by the generator
    % polynomial the result is zero)
    Synd = polyval(reccode, alpha .^ (1:k));
    syndrome = trim(Synd)

    %}
   
    %sum = syndrome*(ones(1,2*t))';
    if isempty(syndrome)
        decoded = orig_vals(1:n-k);
        error_pos = [];
        error_mag = [];
        g = [];
        S = alpha_tb;
        return;
    end
    %syndrome = mod(syndrome.x,2)
     % Prepare for the euclidean algorithm (Used to find the error locating
        % polynomials)
        r0 = [1, zeros(1, 2*max_errors)];r0 = gf(r0, m, prim_poly);r0 = trim(r0);
        size_r0 = length(r0);
        r1 = syndrome;
        f0 = gf([zeros(1, size_r0-1) 1], m, prim_poly);
        f1 = gf(zeros(1, size_r0), m, prim_poly);
        g0 = f1; g1 = f0;
        % Do the euclidean algorithm on the polynomials r0(x) and syndrome(x) in
        % order to find the error locating polynomial

        while true
            % Do a long division
            [quotient, remainder] = deconv(r0, r1);
            % Add some zeros
            quotient = pad(quotient, length(g1));
           %quotient = [quotient zeros(1, length(g1)- length(quotient))];
            % Find quotient*g1 and pad
            c = conv(quotient, g1);
            c = trim(c);
            c = pad(c, length(g0));
            %c = [c zeros(1, length(g0)- length(c))];
            % Update g as g0-quotient*g1
            g = g0 - c;
            % Check if the degree of remainder(x) is less than max_errors
            if all(remainder(1:end - max_errors) == 0)
                break;
            end

            % Update r0, r1, g0, g1 and remove leading zeros
            r0 = trim(r1); 
            r1 = trim(remainder);
            g0 = g1;
            g1 = g;
        end

    % Remove leading zeros
    g =  g + 0;
    g = trim(g);
    %g = mod(g.x,2);
    %g = gf(g,m);
    % Find the zeros of the error polynomial on this galois field
    evalPoly = polyval(g, alpha .^ (n-1 : -1 : 0));
    error_pos = gf(find(evalPoly == 0), m);
    % If no error position is found we return the received work, because
    % basically is nothing that we could do and we return the received message
    if isempty(error_pos)
        decoded = orig_vals(1:k);
        error_mag = [];
        return;
    end
    % Prepare a linear system to solve the error polynomial and find the error
    % magnitudes
    size_error = length(error_pos);
    syndromee_Vals = syndrome.x;
    b(:, 1) = syndromee_Vals(1:size_error);
    for idx = 1 : size_error
        e = alpha .^ (idx*(error_pos.x));
        err = e.x;
        er(idx, :) = err;
    end
    
    % Solve the linear system
    %error_mag = (gf(er, m, prim_poly) \ gf(b, m, prim_poly))';
    %error_mag = mod(error_mag.x,2);
    error_mag = 1;
    errors = [zeros(1,63)];
    % Put the error magnitude on the error vector
    errors(error_pos.x) = error_mag;
    % Bring this vector to the galois field
    errors_gf = gf(errors, m, prim_poly);
     
    % Now to fix the errors just add with the reccode code
    decoded_gf = reccode(1:n) + errors_gf(1:n);%n-k
    decoded1 = decoded_gf.x;
    decode = decoded1(1:n-k+1);
    
     res =  encoded(2:n+1) - decoded1 ;
        decoded = decode;
end