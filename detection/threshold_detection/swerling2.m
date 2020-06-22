function PD = swerling2(SNR_dB, Pfa, N)
    % ====== Swerling II =======================================================
    SNR = db2pow(SNR_dB);
    T = gammaincinv(1 - Pfa, N);

    PD = 1 - gammainc(T ./ (1 + SNR), N);