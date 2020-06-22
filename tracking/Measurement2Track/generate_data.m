% clear; close all; clc;
clear;

% 《雷达数据处理基础（第三版）》P152

lambda = 1000;

step_num = 100;
q1 = 0.04;
q2 = 0.03;
r = 10;
T = 1;

target = {};
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

for ii = 2:step_num
    F = target{1}.F;
    Q = target{1}.Q;
    target{1}.X(:, ii) = F * target{1}.X(:, ii-1) + mvnrnd(zeros(4, 1), Q)';
end

target{1}.Z = target{1}.H * target{1}.X + mvnrnd(zeros(2, 1), target{1}.R, step_num)';


% 整理量测值，合并杂波与目标轨迹量测值
max_x = max(target{1}.Z(1, :));
min_x = min(target{1}.Z(1, :));
max_y = max(target{1}.Z(2, :));
min_y = min(target{1}.Z(2, :));
left = min_x - (max_x - min_x) / 4;
right = max_x + (max_x - min_x) / 4;
bottom = min_y - (max_y - min_y) / 4;
top = max_y + (max_y - min_y) / 4;

measurement = cell(1, step_num);
for ii = 1:step_num
    jam_num = poissrnd(lambda);
    jam_x = left + (right - left) * rand(1, jam_num);
    jam_y = bottom + (top - bottom) * rand(1, jam_num);
    measurement{ii} = [target{1}.Z(:, ii), [jam_x; jam_y]];
end



% % 可视化轨迹
% figure;
% hold on;
% plot(target{1}.X(1, :), target{1}.X(3, :), 'k-');
% plot(target{1}.Z(1, :), target{1}.Z(2, :), '-.');
% xlim([left, right]);
% ylim([bottom, top]);

% % 可视化杂波
% for ii = 1:step_num
%     plot(measurement{ii}(1, :), measurement{ii}(2, :), 'k.');
%     % pause(0.1);
% end

save data;