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
sigma_omega = 16;
sigma_v = 1;

X = zeros(2, num_step + 1);
Z = [];
real_track = [];
X(:, 1) = [0, 10]';

% NCV
for k = 1:num_step
    X(1:2, k + 1) = F_NCV * X(1:2, k) + G_NCV * sigma_v * randn();
end

real_track = H_NCV * X;
real_velocity = X(2, :);
real_accelerate = zeros(size(real_velocity));
Z = H_NCV * X + sigma_omega * randn(1, num_step + 1);

save data_cv2;

% 可视化
figure;
t = 0:120;
plot(t, real_track, 'k-', 'LineWidth', 1.5);
hold on;
plot(t, Z, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
grid on;