clear; close all; clc;

% ====== �������˲� ======
% ===========================

load data;

% ====== �������˲� NCA ======

% ���ӻ�����
figure;
t = 0:120;
plot(t, real_track, 'k-', 'LineWidth', 1.5, 'Color', [0.7, 0.7, 0.7]);
hold on;
% plot(t, X_std(1, :), 'k--'); % ����׼ģ�͹켣���޹���������
plot(t, Z, 'o', 'MarkerSize', 3, 'MarkerFaceColor', [0.5, 0.5, 0.5]);
grid on;

% �˲�
Q = sigma_v ^ 2;
r = sigma_omega;
R = r^2;

X_estimate = zeros(3, num_step + 1);
K_kalman = zeros(3, num_step + 1);
P_estimate = zeros(3, 3, num_step + 1);

X_estimate(:, 1) = [Z(1); ...
                    (Z(2) - Z(1)) / T; ...
                    (Z(1) + Z(3) - 2*Z(2)) / T^2];
P_estimate(:, :, 1) = [r      r/T      r/T^2; ...
                       r/T    2*r/T^2  3*r/T^3; ...
                       r/T^2  3*r/T^3  6*r/T^4];

% [X_next, P_next] = kalman(Z, Xkk, Pkk, F, G, H, Q, R)
for ind = 1:num_step
    [X_estimate(:, ind+1), P_estimate(:, :, ind+1), K_kalman(:, ind+1)] = ...
        kalman(Z(ind+1), X_estimate(:, ind), P_estimate(:, :, ind), F_NCA, G_NCA, H_NCA, Q, R);
end

plot(t, X_estimate(1, :), 'k-', 'LineWidth', 1.5);
% title('NCA�������˲�');
xlabel('ʱ��/s');
ylabel('����/m')
legend('��ʵ�켣', '����ֵ', '�˲��켣');

figure;
subplot(211);
hold on;
grid on;
plot(t, real_velocity, 'k-', 'LineWidth', 1.5, 'Color', [0.7, 0.7, 0.7]);
plot(t, X_estimate(2, :), 'k-', 'LineWidth', 1.5);
% title('NCA�ٶ�');
xlabel('ʱ��/s');
ylabel('�ٶ�/m��s^{-1}');
legend('��ʵ�켣', '�˲��켣');

% figure;
subplot(212);
hold on;
grid on;
plot(t, real_accelerate, 'k-', 'LineWidth', 1.5, 'Color', [0.7, 0.7, 0.7]);
plot(t, X_estimate(3, :), 'k-', 'LineWidth', 1.5);
% title('NCA�ٶ�');
xlabel('ʱ��/s');
ylabel('���ٶ�/m��s^{-1}');
legend('��ʵ�켣', '�˲��켣');

figure;
subplot(411);
hold on;
grid on;
plot(2:num_step + 1, K_kalman(1, 2:end), 'k-', 'linewidth', 1.5);
plot(2:num_step + 1, K_kalman(2, 2:end), 'b-', 'linewidth', 1.5);
plot(2:num_step + 1, K_kalman(3, 2:end), 'r-', 'linewidth', 1.5);
% title('NCV K');
legend('K[1]', 'K[2]', 'K[3]');
xlabel('ʱ��/s');

P_pos = P_estimate(1, 1, :);
P_pos = P_pos(:);
P_vel = P_estimate(2, 2, :);
P_vel = P_vel(:);
P_acc = P_estimate(3, 3, :);
P_acc = P_acc(:);

subplot(412);
plot(2:num_step + 1, P_pos(2:end), 'k-', 'linewidth', 1.5);
grid on;
gtext('λ�����Э����');
xlabel('ʱ��/s');

subplot(413);
plot(2:num_step + 1, P_vel(2:end), 'k-', 'linewidth', 1.5);
grid on;
gtext('�ٶ����Э����');
xlabel('ʱ��/s');

subplot(414);
plot(2:num_step + 1, P_acc(2:end), 'k-', 'linewidth', 1.5)
grid on;
gtext('���ٶ����Э����');
xlabel('ʱ��/s');
