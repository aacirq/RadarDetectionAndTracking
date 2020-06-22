clear; close all; clc;
rng('default');

% ====== 重写 ==================================================================

scan_num = 4;
target_num = 5;
T = 5;
lambda = 150;
sigma_omega = 2;
q = 2;
scale = 1e4;


target = cell(1, target_num);
measurement = cell(1, target_num);

target{1}.X = [5500;  0;    7000;  50];
target{2}.X = [4500;  35;   6000;  -35];
target{3}.X = [3500;  50;   5000;  0];
target{4}.X = [4500;  -35;  4000;  -35];
target{5}.X = [5500;  0;    3000;  50];

% 设定F矩阵
for ii = 1:target_num
    target{ii}.F = [1 T 0 0; 0 1 0 0; 0 0 1 T; 0 0 0 1];
    target{ii}.Q = init_Q(T, q);
end

% 目标运动
for t = 2:scan_num
    for ii = 1:target_num
        target{ii}.X(:, t) = target{ii}.F * target{ii}.X(:, t-1) + mvnrnd(zeros(4, 1), target{ii}.Q)';
    end
end

% 量测
for ii = 1:target_num
    measurement{ii}.H = [1 0 0 0; 0 0 1 0];
    measurement{ii}.Z = measurement{ii}.H * target{ii}.X + (sigma_omega ^ 2) * randn(2, scan_num);
end

% 合并数据
points = cell(1, scan_num);
for t = 1:scan_num
    points{t} = [];
    for ii = 1:target_num
        Z = measurement{ii}.Z;
        points{t}(:, end + 1) = Z(:, t);
    end
end

% 产生杂波
for t = 1:scan_num
    n = poissrnd(lambda);
    new_points = scale * rand(2, n);
    points{t} = [points{t}, new_points];
end


% 保存数据
save data_150


% 可视化
figure;
hold on;
grid on;
plot(points{1}(1, :), points{1}(2, :), 'b*', 'linewidth', 1, 'markersize', 5);
plot(points{2}(1, :), points{2}(2, :), 'bs', 'linewidth', 1, 'markersize', 5);
plot(points{3}(1, :), points{3}(2, :), 'bo', 'linewidth', 1, 'markersize', 5);
plot(points{4}(1, :), points{4}(2, :), 'b+', 'linewidth', 1, 'markersize', 5);

for ii = 1:target_num
    plot(measurement{ii}.Z(1, :), measurement{ii}.Z(2, :), 'rx', 'linewidth', 2, 'markersize', 8);
end

xlim([0, scale]); ylim([0, scale]);