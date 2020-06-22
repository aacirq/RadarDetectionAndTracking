% 直观法航迹起始
clear; close all; clc;

load data_150;

% ====== 可视化 ================================================================
figure;
hold on;
grid on;
plot(points{1}(1, :), points{1}(2, :), '*', 'linewidth', 1, 'markersize', 8, 'color', 0.7 * ones(3, 1));
plot(points{2}(1, :), points{2}(2, :), 's', 'linewidth', 1, 'markersize', 8, 'color', 0.7 * ones(3, 1));
plot(points{3}(1, :), points{3}(2, :), 'o', 'linewidth', 1, 'markersize', 8, 'color', 0.7 * ones(3, 1));
plot(points{4}(1, :), points{4}(2, :), '+', 'linewidth', 1, 'markersize', 8, 'color', 0.7 * ones(3, 1));

for ii = 1:target_num
    plot(measurement{ii}.Z(1, :), measurement{ii}.Z(2, :), 'rx', 'linewidth', 0.5, 'markersize', 5);
end

xlim([0, scale]); ylim([0, scale]);

% ====== 处理 ==================================================================
Vmax = 80;
Vmin = 20;
a_max = 5;

trajectory = {};
for ii = 1:length(points{1})
    trajectory{ii}.X = points{1}(:, ii);
    trajectory{ii}.delete_flag = 0;  % 0-不删除, 1-删除
end

for t = 2:scan_num
    LEN = length(trajectory);
    next_meas = points{t};
    LEN_next = length(next_meas);
    % 互联
    for ii = 1:LEN
        v = sqrt(sum((trajectory{ii}.X(:, end) * ones(1, LEN_next) - next_meas) .^ 2, 1)) ./ T;
        able_ind = find(v <= Vmax & v >= Vmin);
        for able_i = 1:length(able_ind)
            trajectory{end + 1}.X = [trajectory{ii}.X, next_meas(:, able_ind(able_i))];
            trajectory{end}.delete_flag = 0;
        end
        trajectory{ii}.delete_flag = 1;
    end
    
    % 删除标记的
    trajectory(1:LEN) = [];
    % pause;

    % 判别加速度
    if t > 2
        for ii = 1:length(trajectory)
            thisX = trajectory{ii}.X;
            v1 = sqrt(sum((thisX(:, t) - thisX(:, t - 1)).^2)) / T;
            v2 = sqrt(sum((thisX(:, t - 1) - thisX(:, t -  2)).^2)) / T;
            if abs(v1 - v2) > a_max * t
                trajectory{ii}.delete_flag = 1;
            end
        end

        % 删除不符合加速度限定的
        ii = 1;
        while ii < length(trajectory)
            if trajectory{ii}.delete_flag == 1
                trajectory(ii) = [];
            else
                ii = ii + 1;
            end
        end
    end
end

% 可视化
% figure;
hold on;
grid on;
for ii = 1:length(trajectory)
    plot(trajectory{ii}.X(1, :), trajectory{ii}.X(2, :), 'k-', 'linewidth', 1);
end

xlim([0, scale]); ylim([0, scale]);
