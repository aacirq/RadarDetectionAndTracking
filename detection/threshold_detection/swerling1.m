function PD = swerling1(SNR_dB, Pfa, N)
    % ====== Swerling I ========================================================
    SNR = db2pow(SNR_dB);
    T = gammaincinv(1 - Pfa, N);

    if N == 1
        PD = exp(-T ./ (1 + SNR_dB));
    elseif N > 1
        tmp = 1 + 1 ./ (N .* SNR);
        part_1 = tmp .^ (N-1);
        part_2 = gammainc(T ./ tmp, N - 1);
        part_3 = exp(-(T ./ (1 + N.*SNR)));
        PD = 1 - gammainc(T, N - 1) + part_1 .* part_2 .* part_3;
    end