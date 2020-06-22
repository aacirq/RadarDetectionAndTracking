function PD = swerling3(SNR_dB, Pfa, N)
    % ====== Swerling III ======================================================
    SNR = db2pow(SNR_dB);
    T = gammaincinv(1 - Pfa, N);

    tmp = 1 + N .* SNR / 2;
    part1 = (1 + 2 ./ (N * SNR)) .^ (N - 2);
    part2 = 1 + T ./ tmp - 2 ./ (N * SNR) .* (N - 2);
    part3 = exp(-T ./ tmp);
    PD = part1 .* part2 .* part3;