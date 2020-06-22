clear; close all; clc;

Pfa = 10^-8;
N = 5;
SNR_dB = linspace(-2, 14, 1000);

SNR = db2pow(SNR_dB);
T = gammaincinv(1 - Pfa, N);

% ====== Swerling V ============================================================
% figure;
% hold on;
% plot(SNR_dB, swerling0(SNR_dB, Pfa, 1));
% plot(SNR_dB, swerling0(SNR_dB, Pfa, 2));
% plot(SNR_dB, swerling0(SNR_dB, Pfa, 5));
% plot(SNR_dB, swerling0(SNR_dB, Pfa, 10));
% plot(SNR_dB, swerling0(SNR_dB, Pfa, 20));
% grid on;
% legend('N=1', 'N=2', 'N=5', 'N=10', 'N=20');
PD_swerling0 = swerling0(SNR_dB, Pfa, N);
figure;
plot(SNR_dB, PD_swerling0, 'k-', 'linewidth', 1);
hold on;
grid on;

% ====== Swerling I ============================================================
PD_swerling1 = swerling1(SNR_dB, Pfa, N);
plot(SNR_dB, PD_swerling1, 'm-', 'linewidth', 1);

% ====== Swerling II ===========================================================
PD_swerling2 = swerling2(SNR_dB, Pfa, N);
plot(SNR_dB, PD_swerling2, 'r-', 'linewidth', 1);

% ====== Swerling III ==========================================================
PD_swerling3 = swerling3(SNR_dB, Pfa, N);
plot(SNR_dB, PD_swerling3, 'g-', 'linewidth', 1);

% ====== Swerling IV ===========================================================
PD_swerling4 = swerling4(SNR_dB, Pfa, N);
plot(SNR_dB, PD_swerling4, 'b-', 'linewidth', 1);

legend('非起伏目标', 'Swerling I', 'Swerling II', ...
       'Swerling III', 'Swerling IV');

xlabel('SNR/dB');
ylabel('检测概率P_D');
title('N=5时不同起伏目标检测概率')