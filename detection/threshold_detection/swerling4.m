function PD = swerling4(SNR_dB, Pfa, N)
    % ====== Swerling IV =======================================================
    % 根据《雷达信号处理基础（第二版）》编的
    SNR = db2pow(SNR_dB);
    T = gammaincinv(1 - Pfa, N);

    PD = zeros(size(SNR));
    for ii = 1:length(SNR)
        fprintf("%d\n", ii);
        c = 1 / (1 + SNR(ii) / 2);
        if T > N * (2 - c)
            for k = 0:N
                syms l;
                s = exp(-c * T) * (c * T) ^ l / factorial(l);
                part1 = symsum(s, 0, 2 * N - k - 1);
                % part1 = 0;
                % for l = 0 : (2 * N - 1 - k)
                %     part1 = part1 + exp(-c * T) * (c * T) ^ l / factorial(l);
                % end
                part2 = factorial(N) / (factorial(k) * factorial(N - k));
                part3 = ((1 - c) / c) ^ (N - k);
                PD(ii) = PD(ii) + part1 * part2 * part3;
            end
            PD(ii) = c ^ N * PD(ii);
        else
            for k = 0:N
                syms l;
                s = exp(-c * T) * (c * T) ^ l / factorial(l);
                part1 = symsum(s, 2 * N - k, inf);
                part2 = factorial(N) / (factorial(k) * factorial(N - k));
                part3 = ((1 - c) / c) ^ (N - k);
                PD(ii) = PD(ii) + part1 * part2 * part3;
            end
            PD(ii) = 1 - c ^ N * PD(ii);
        end
    end


    % 根据swerling文献中编的。适用情况有限
    % beta = 1 + SNR / 2;
    % tau = (T - N .* (1 + SNR)) ./ sqrt(N .* (2 * beta .^ 2 - 1));
    % C3 = 1 / (3 * sqrt(N)) .* ((2 * beta .^ 3 - 1) ./ (2 * beta .^ 2 - 1) .^ 1.5);
    % C4 = 1 / (4 * N) .* ((2 * beta .^ 4 - 1) ./ (2 * beta .^ 2 - 1) .^ 2);
    % C6 = 1 / (18 * N) .* ((2 * beta .^ 3 - 1) .^ 2 ./ (2 * beta .^ 2 - 1) .^ 3);
    % PD_swerling4 = 0.5 .* (1 - phi_1(tau)) - C3 .* phi2(tau) - C4 .* phi3(tau) - C6 .* phi5(tau);
    % plot(SNR_dB, PD_swerling4);

    % function y = phi_1(tau)
    %     y = zeros(size(tau));
    %     len = length(tau);
    %     f = @(t) exp(-0.5 * t.^2);
    %     for ii = 1:len
    %         y(ii) = 1 ./ sqrt(2 * pi) .* integral(f, -tau(ii), tau(ii));
    %     end
    % end
    % function y = phi2(t)
    %     y = 1 ./ sqrt(2 * pi) .* (t .^ 2 - 1) .* exp(-0.5 .* t .^ 2);
    % end
    % function y = phi3(t)
    %     y = 1 ./ sqrt(2 * pi) .* (3 .* t - t .^ 3) .* exp(-0.5 .* t .^ 2);
    % end
    % function y = phi5(t)
    %     part = 10 .* t .^ 3 - 15 .* t - t .^ 5;
    %     y = 1 ./ sqrt(2 * pi) .* part .* exp(-0.5 .* t .^ 2);
    % end