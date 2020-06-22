clear; close all; clc;
% ====== Monte Carlo 非起伏目标 ================================================
sim_time = 1000;

num_cell = 200;
target_pos = 100;
noise_power_dB = 20;
SNR_dB = 15;
Pfa = 1e-8;
PD = zeros(size(SNR_dB));
N = 5;

detected_ind = [];
t = 1;

% while length(detected_ind) <= 1
    if mod(t, 10000) == 0
        fprintf("t = %d \n", t);
    end
    t = t + 1;
    noise_power = db2pow(noise_power_dB);
    T = noise_power * gammaincinv(1 - Pfa, N);

    noise = randn(N, num_cell) + 1j * randn(N, num_cell);
    % noise = sum(noise, 3);
    noise = sqrt(noise_power / 2) * noise;

    echo_mod = sqrt(noise_power * db2pow(SNR_dB));
    echo_signal = echo_mod * exp(1j * 2 * pi * rand());

    signal = noise;
    signal(:, target_pos) = signal(:, target_pos) + echo_signal;
    signal_mod = sum(abs(signal) .^ 2, 1);

    detected_ind = find(signal_mod > T);
% end

plot(1:num_cell, pow2db(signal_mod), 'k', 'linewidth', 1);
hold on;
plot([0, 200], [pow2db(T), pow2db(T)], '--', 'linewidth', 2, 'color', 0.7*ones(1, 3));
plot(detected_ind, pow2db(signal_mod(1, detected_ind)), 'ro', 'markersize', 10, 'linewidth', 1);
grid on;
legend('信号', '阈值', '发现目标');
xlabel('距离单元');
ylabel('幅度(dB)');