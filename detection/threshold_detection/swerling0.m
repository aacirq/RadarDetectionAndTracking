function PD = swerling0(SNR_dB, Pfa, N)
    % ====== Swerling V ========================================================
    SNR = db2pow(SNR_dB);
    T = gammaincinv(1 - Pfa, N);

    tmp = 0;
    for r = 2:N
        tmp = tmp + (T ./ (N .* SNR)).^((r - 1) / 2) .* ...
              besseli(r - 1, 2 * sqrt(N .* SNR .* T));
    end
    PD = marcumq(sqrt(2 * N .* SNR), sqrt(2 * T)) + exp(-(T + N * SNR)) .* tmp;