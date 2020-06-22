% clear; close all; clc;
clear;

% 《雷达数据处理基础（第三版）》P152
% 多目标情景

lambda = 1000;

step_num = 100;
q1 = 0.04;
q2 = 0.03;
r = 10;
T = 1;

target = {};
% ====== target 1 ======
target{1}.X = zeros(4, step_num);
target{1}.X(:, 1) = [10, 6, 10, -15]';

target{1}.F = [1  T  0  0;
            0  1  0  0;
            0  0  1  T;
            0  0  0  1];
target{1}.H = [1 0 0 0; 0 0 1 0];
G = [0.5*T^2  0;  T  0;  0  0.5*T^2;  0  T];
target{1}.Q = G * [q1 0; 0 q2] * G';
target{1}.R = r^2 * eye(2);
% ====== target 2 ======
target{2}.X = zeros(4, step_num);
target{2}.X(:, 1) = [0, 6, -1000, 15]';

target{2}.F = [1  T  0  0;
            0  1  0  0;
            0  0  1  T;
            0  0  0  1];
target{2}.H = [1 0 0 0; 0 0 1 0];
G = [0.5*T^2  0;  T  0;  0  0.5*T^2;  0  T];
target{2}.Q = G * [q1 0; 0 q2] * G';
target{2}.R = r^2 * eye(2);
% ====== target 3 ======
target{3}.X = zeros(4, step_num);
target{3}.X(:, 1) = [0, 6, 600, -10]';

target{3}.F = [1  T  0  0;
            0  1  0  0;
            0  0  1  T;
            0  0  0  1];
target{3}.H = [1 0 0 0; 0 0 1 0];
G = [0.5*T^2  0;  T  0;  0  0.5*T^2;  0  T];
target{3}.Q = G * [q1 0; 0 q2] * G';
target{3}.R = r^2 * eye(2);
% ======

for ii = 2:step_num
    F = target{1}.F;
    Q = target{1}.Q;
    target{1}.X(:, ii) = F * target{1}.X(:, ii-1) + mvnrnd(zeros(4, 1), Q)';

    F = target{2}.F;
    Q = target{2}.Q;
    target{2}.X(:, ii) = F * target{2}.X(:, ii-1) + mvnrnd(zeros(4, 1), Q)';

    F = target{3}.F;
    Q = target{3}.Q;
    target{3}.X(:, ii) = F * target{3}.X(:, ii-1) + mvnrnd(zeros(4, 1), Q)';
end

target{1}.Z = target{1}.H * target{1}.X + mvnrnd(zeros(2, 1), target{1}.R, step_num)';
target{2}.Z = target{2}.H * target{2}.X + mvnrnd(zeros(2, 1), target{1}.R, step_num)';
target{3}.Z = target{3}.H * target{3}.X + mvnrnd(zeros(2, 1), target{1}.R, step_num)';


% 整理量测值，合并杂波与目标轨迹量测值
max_x = max([max(target{1}.Z(1, :)), max(target{2}.Z(1, :)), max(target{2}.Z(1, :))]);
min_x = min([min(target{1}.Z(1, :)), min(target{2}.Z(1, :)), min(target{2}.Z(1, :))]);
max_y = max([max(target{1}.Z(2, :)), max(target{2}.Z(2, :)), max(target{2}.Z(2, :))]);
min_y = min([min(target{1}.Z(2, :)), min(target{2}.Z(2, :)), min(target{2}.Z(2, :))]);
left = min_x - (max_x - min_x) / 4;
right = max_x + (max_x - min_x) / 4;
bottom = min_y - (max_y - min_y) / 4;
top = max_y + (max_y - min_y) / 4;

measurement = cell(1, step_num);
for ii = 1:step_num
    jam_num = poissrnd(lambda);
    jam_x = left + (right - left) * rand(1, jam_num);
    jam_y = bottom + (top - bottom) * rand(1, jam_num);
    measurement{ii} = [target{1}.Z(:, ii), target{2}.Z(:, ii), target{3}.Z(:, ii), [jam_x; jam_y]];
end



% % 可视化轨迹
% figure;
% hold on;
% plot(target{1}.X(1, :), target{1}.X(3, :), 'k-');
% plot(target{1}.Z(1, :), target{1}.Z(2, :), '-.');
% xlim([left, right]);
% ylim([bottom, top]);
% plot(target{2}.X(1, :), target{2}.X(3, :), 'k-');
% plot(target{2}.Z(1, :), target{2}.Z(2, :), '-.');

% plot(target{3}.X(1, :), target{3}.X(3, :), 'k-');
% plot(target{3}.Z(1, :), target{3}.Z(2, :), '-.');

% % 可视化杂波
% figure;
% hold on;
% for ii = 1:step_num
%     plot(measurement{ii}(1, :), measurement{ii}(2, :), 'k.');
%     % pause(0.1);
% end
% xlim([left, right]);
% ylim([bottom, top]);

target_num = 3;
save data2;