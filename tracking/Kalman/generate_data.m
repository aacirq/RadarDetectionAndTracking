clear; close all; clc;

% ====== 参数估计-产生运动数据 ======
T = 1;
F_NCV = [1 T; 0 1];
H_NCV = [1 0];
G_NCV = [0.5 * T^2 T]';
F_NCA = [1 T 0.5*T^2; 0 1 T; 0 0 1];
H_NCA = [1 0 0];
G_NCA = [0.5 * T^2 T 1]';
num_step = 120;
sigma_omega = 120;
sigma_v = 2;

X = zeros(3, num_step + 1);
X_std = zeros(3, num_step + 1);
Z = [];
real_track = [];
X(:, 1) = [150, -20, 0]';
X_std(:, 1) = [150, -20, 0]';

% NCV
for ind = 1:20
    X_std(:, ind + 1) = F_NCA * X_std(:, ind);
    X(1:2, ind + 1) = F_NCV * X(1:2, ind) + G_NCV * sigma_v * randn();
end
XN(3, 21) = 10;
X_std(3, 21) = 10;
% NCA 10m/s^2
for ind = 21:30
    X_std(:, ind + 1) = F_NCA * X_std(:, ind);
    X(:, ind + 1) = F_NCA * X(:, ind) + G_NCA * sigma_v * randn();
end
X(3, 31) = 0;
X_std(3, 31) = 0;
% NCV
for ind = 31:70
    X_std(:, ind + 1) = F_NCA * X_std(:, ind);
    X(1:2, ind + 1) = F_NCV * X(1:2, ind) + G_NCV * sigma_v * randn();
end
XN(3, 71) = -10;
X_std(3, 71) = -10;
% NCA -10m/s^2
for ind = 71:80
    X_std(:, ind + 1) = F_NCA * X_std(:, ind);
    X(:, ind + 1) = F_NCA * X(:, ind) + G_NCA * sigma_v * randn();
end
X(3, 81) = 0;
X_std(3, 81) = 0;
% NCV
for ind = 81:120
    X_std(:, ind + 1) = F_NCA * X_std(:, ind);
    X(1:2, ind + 1) = F_NCV * X(1:2, ind) + G_NCV * sigma_v * randn();
end

real_track = H_NCA * X;
real_velocity = X(2, :);
real_accelerate = X(3, :);
Z = H_NCA * X + sigma_omega * randn(1, num_step + 1);

save data;

% 可视化
figure;
t = 0:120;
plot(t, real_track, 'k-', 'LineWidth', 1.5);
hold on;
plot(t, X_std(1, :), 'k--');
plot(t, Z, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
grid on;