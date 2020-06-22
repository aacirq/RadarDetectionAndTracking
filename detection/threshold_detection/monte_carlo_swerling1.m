clear; close all; clc;
% ====== Monte Carlo 非起伏目标 ================================================
sim_time = 1000;

num_cell = 200;
target_pos = 100;
noise_power_dB = 20;
SNR_dB = linspace(0, 20, 100);
Pfa = 1e-8;
PD = zeros(size(SNR_dB));
N = 2;

noise_power = db2pow(noise_power_dB);
T = noise_power * gammaincinv(1 - Pfa, N);

for ii = 1:length(SNR_dB)
    fprintf("SNR: %f dB\n", SNR_dB(ii));

    noise = randn(sim_time, num_cell, N) + 1j * randn(sim_time, num_cell, N);
    noise = sqrt(noise_power / 2) .* noise;

    SNR_rnd = exprnd(db2pow(SNR_dB(ii)), sim_time, 1);
    echo_mod = sqrt(noise_power .* SNR_rnd);
    echo_signal = echo_mod .* exp(1j * 2 * pi * rand(sim_time, 1));

    signal = noise;
    for jj = 1:N
        signal(:, target_pos, jj) = signal(:, target_pos, jj) + echo_signal;
    end
    signal_mod = abs(signal) .^ 2;
    
    % sum(signal_mod(:, target_pos) > T)
    PD(ii) = sum(signal_mod(:, target_pos) > T) / sim_time;
end

PD_swerling1 = swerling1(SNR_dB, Pfa, N);
PD_swerling2 = swerling2(SNR_dB, Pfa, N);

figure();
plot(SNR_dB, PD);
hold on;
plot(SNR_dB, PD_swerling1);
plot(SNR_dB, PD_swerling2);
grid on;

xlabel('SNR/dB');
ylabel('检测概率P_D');
legend('Monte Carlo检测概率', '理想检测概率1', '理想检测概率2');