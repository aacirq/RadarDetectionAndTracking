clear; close all; clc;
% ====== Monte Carlo 非起伏目标 ================================================
sim_time = 1000;

num_cell = 200;
target_pos = 100;
noise_power_dB = 20;
SNR_dB = linspace(0, 20, 100);
Pfa = 1e-8;
PD = zeros(size(SNR_dB));
N = 10;

noise_power = db2pow(noise_power_dB);
T = noise_power * gammaincinv(1 - Pfa, N);

for ii = 1:length(SNR_dB)
    fprintf("SNR: %f dB\n", SNR_dB(ii));
    
    noise = randn(sim_time, num_cell, N) + 1j * randn(sim_time, num_cell, N);
    % noise = sum(noise, 3);
    noise = sqrt(noise_power / 2) * noise;

    echo_mod = sqrt(noise_power * db2pow(SNR_dB(ii)));
    echo_signal = echo_mod * exp(1j * 2 * pi * rand());

    signal = noise;
    signal(:, target_pos, :) = signal(:, target_pos, :) + echo_signal;
    signal_mod = sum(abs(signal) .^ 2, 3);
    
    % sum(signal_mod(:, target_pos) > T)
    PD(ii) = sum(signal_mod(:, target_pos) > T) / sim_time;
end

PD_swerling0 = swerling0(SNR_dB, Pfa, N);

figure();
plot(SNR_dB, PD);
hold on;
plot(SNR_dB, PD_swerling0);
grid on;

xlabel('SNR/dB');
ylabel('检测概率P_D');
legend('Monte Carlo检测概率', '理想检测概率');