function TEP_t = impulsion(d_0, d_1, K, N, EbN0, trellis)
    v = zeros(1, K); 
    xu = zeros(K, 1); % All-zero message
    R = K / N;

    % Encode the all-zero message
    c_zero = cc_encode(xu, trellis);
    c_zero = c_zero(:); % Ensure column vector

    % Modulate the all-zero codeword
    x_zero = 1 - 2 * c_zero;

    % For each bit position
    for l = 1:K
        A = d_0 - 0.5; 
        xuhat = xu; 
        while (isequal(xu, xuhat) && (A <= d_1))
            A = A + 1; 

            % Create message with an impulse at position l
            u_impulse = zeros(K, 1);
            u_impulse(l) = 1;

            % Encode the impulse message
            c_impulse = cc_encode(u_impulse, trellis);
            c_impulse = c_impulse(:);

            % Compute the difference between codewords
            delta_c = mod(c_zero + c_impulse, 2);

            % Modulate the difference
            x_delta = 1 - 2 * delta_c;

            % Apply impulse
            y = x_zero - A * x_delta;

            % Decision hard
            r = y < 0;

            % Decode
            xuhat = viterbi_decode(r, trellis);
            xuhat = xuhat(1:K); % Take only the first K bits
        end
        v(l) = floor(A);
    end

    % Compute Ad for each unique d in v
    D = unique(v);
    Ad = zeros(size(D));
    for i = 1:length(D)
        d = D(i);
        Ad(i) = sum(v == d);
    end

    % Compute TEP_t for each EbN0
    TEP_t = zeros(size(EbN0));
    for idx = 1:length(EbN0)
        current_EbN0 = EbN0(idx);
        TEP_t(idx) = (1 / (2 * K)) * sum(Ad .* erfc(sqrt(2 * D * R * current_EbN0)));
    end
end