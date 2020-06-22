clear; close all; clc;
% �Ӳ���Ե����©������

MC_num = 1000; % Monte Carlo����

num_unit = 200;
noise_power_dB1 = 20;
Pfa = 1e-3;

% % ====== ��һ��©���ʾ�� ======================================================
% [signal, pos, thres, start_cell, stop_cell] = getASample(noise_power_dB1, 30, Pfa);
% figure;
% hold on;
% grid on;
% plot(1:num_unit, pow2db(signal), 'k-', 'linewidth', 0.5);
% plot(start_cell:stop_cell, pow2db(thres), 'k--', 'linewidth', 1);
% plot(95, pow2db(signal(1, 95)), 'bo', 'linewidth', 1);
% xlabel('���뵥Ԫ');
% ylabel('����(dB)');
% legend('�ź�', 'CA CFAR��ֵ', 'ʵ��Ŀ��');
% pause;


% % ====== ��ͬSNR�¼��������� =================================================
% [detection_times1, start_cell, stop_cell] = MCSim(noise_power_dB1, 30, Pfa, 10, MC_num, num_unit);
% [detection_times2, start_cell, stop_cell] = MCSim(noise_power_dB1, 30, Pfa, 12.5, MC_num, num_unit);
% [detection_times3, start_cell, stop_cell] = MCSim(noise_power_dB1, 30, Pfa, 15, MC_num, num_unit);

% figure;
% subplot(211);
% hold on;
% grid on;
% plot(start_cell:stop_cell, detection_times1(1, start_cell:stop_cell) ./ MC_num, 'k-', 'linewidth', 0.5);
% plot(start_cell:stop_cell, detection_times2(1, start_cell:stop_cell) ./ MC_num, 'r-', 'linewidth', 0.5);
% plot(start_cell:stop_cell, detection_times3(1, start_cell:stop_cell) ./ MC_num, 'b-', 'linewidth', 0.5);
% xlabel('���뵥Ԫ');
% ylabel('������P_D');
% legend('SNR=10dB', 'SNR=12.5dB', 'SNR=15dB');

% subplot(212);
% hold on;
% grid on;
% plot(start_cell:stop_cell, detection_times1(1, start_cell:stop_cell) ./ MC_num, 'k-', 'linewidth', 0.5);
% plot(start_cell:stop_cell, detection_times2(1, start_cell:stop_cell) ./ MC_num, 'r-', 'linewidth', 0.5);
% plot(start_cell:stop_cell, detection_times3(1, start_cell:stop_cell) ./ MC_num, 'b-', 'linewidth', 0.5);
% xlabel('���뵥Ԫ');
% ylabel('������P_D');
% legend('SNR=10dB', 'SNR=12.5dB', 'SNR=15dB');
% xlim([80, 120]);

% ====== �������ʲ�ͬ ���������� =============================================
[detection_times4, start_cell, stop_cell] = MCSim(noise_power_dB1, 24, Pfa, 15, MC_num, num_unit);
[detection_times5, start_cell, stop_cell] = MCSim(noise_power_dB1, 27, Pfa, 15, MC_num, num_unit);
[detection_times6, start_cell, stop_cell] = MCSim(noise_power_dB1, 30, Pfa, 15, MC_num, num_unit);
save 'res_data/cacfar_����4_��ͬ���������¼���������';

figure;
subplot(211);
hold on;
grid on;
plot(start_cell:stop_cell, detection_times4(1, start_cell:stop_cell) ./ MC_num, 'k-', 'linewidth', 0.5);
plot(start_cell:stop_cell, detection_times5(1, start_cell:stop_cell) ./ MC_num, 'r-', 'linewidth', 0.5);
plot(start_cell:stop_cell, detection_times6(1, start_cell:stop_cell) ./ MC_num, 'b-', 'linewidth', 0.5);
xlabel('���뵥Ԫ');
ylabel('������P_D');
legend('24dB', '27dB', '30dB');

subplot(212);
hold on;
grid on;
plot(start_cell:stop_cell, detection_times4(1, start_cell:stop_cell) ./ MC_num, 'k-', 'linewidth', 0.5);
plot(start_cell:stop_cell, detection_times5(1, start_cell:stop_cell) ./ MC_num, 'r-', 'linewidth', 0.5);
plot(start_cell:stop_cell, detection_times6(1, start_cell:stop_cell) ./ MC_num, 'b-', 'linewidth', 0.5);
xlabel('���뵥Ԫ');
ylabel('������P_D');
legend('24dB', '27dB', '30dB');
xlim([80, 120]);



function [detection_times, start_cell, stop_cell] = MCSim(noise_power_dB1, noise_power_dB2, Pfa, ...
                                                          pos_SNR_dB, MC_num, num_unit)
    detection_times = zeros(1, num_unit);

    for pos_target = 12:200-11
        fprintf("target position: %d\n", pos_target);
        for ii = 1:MC_num
            if pos_target <= 100
                signal1 = generateDataGaussianWhite(100, pos_target, ...
                                                    pos_SNR_dB + noise_power_dB1, noise_power_dB1);
                signal2 = generateDataGaussianWhite(100, [], ...
                                                    [], noise_power_dB2);
            else
                signal1 = generateDataGaussianWhite(100, [], ...
                                                    [], noise_power_dB1);
                signal2 = generateDataGaussianWhite(100, pos_target - 100, ...
                                                    pos_SNR_dB + noise_power_dB2, noise_power_dB2);
            end
            signal = [signal1, signal2];
            [pos, thres, start_cell, stop_cell] = cacfar(signal, Pfa, 10, 2);
        
            if ~isempty(find(pos == pos_target))
                detection_times(1, pos_target) = detection_times(1, pos_target) + 1;
            end
        end
    end
end

function [signal, pos, thres, start_cell, stop_cell] = getASample(noise_power_dB1, noise_power_dB2, Pfa)
    pos = [95];
    while ~isempty(find(pos == 95))
        signal1 = generateDataGaussianWhite(100, [95], ...
                                    15 + noise_power_dB1, noise_power_dB1);
        signal2 = generateDataGaussianWhite(100, [], ...
                                    [], noise_power_dB2);
        signal = [signal1, signal2];
        [pos, thres, start_cell, stop_cell] = cacfar(signal, Pfa, 10, 2);
    end
end