clear; close all; clc;
% 逻辑法航迹起始

load data_150
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
radar_location = [0, 0];
sigma_rho = 40;
sigma_theta = 0.3 * pi / 180;
ok_num_thres = 3;
% 波门门限
gamma = 3e7;

trajectory = {};
for ii = 1:length(points{1})
    trajectory{ii}.X = points{1}(:, ii);
    trajectory{ii}.delete_flag = 0;  % 0-不删除, 1-删除
    trajectory{ii}.ok_num = 1;
end

% 速度法确定第二个
t = 2;
LEN = length(trajectory);
next_meas = points{t};
LEN_next = length(next_meas);
% 互联
for ii = 1:LEN
    v = sqrt(sum((trajectory{ii}.X(:, end) * ones(1, LEN_next) - next_meas) .^ 2, 1)) ./ T;
    able_ind = find(v <= Vmax & v >= Vmin);
    for able_i = 1:length(able_ind)
        trajectory{end + 1}.X = init_X(trajectory{ii}.X, next_meas(:, able_ind(able_i)), T);
        % trajectory{end + 1}.X = [trajectory{ii}.X, next_meas(:, able_ind(able_i))];
        trajectory{end}.delete_flag = 0;
        trajectory{end}.F = [1 T 0 0; 0 1 0 0; 0 0 1 T; 0 0 0 1];
        trajectory{end}.Q = init_Q(T, q);
        trajectory{end}.R = get_R(next_meas(:, able_ind(able_i)), radar_location, sigma_rho, sigma_theta);
        trajectory{end}.H = [1 0 0 0; 0 0 1 0];
        trajectory{end}.P = init_P(trajectory{end}.R, T);
        trajectory{end}.ok_num = 2;
    end
    trajectory{ii}.delete_flag = 1;
end

% 删除未更新的
trajectory(1:LEN) = [];
% pause;

% 外推并更新
for t = 3:scan_num
    LEN = length(trajectory);
    next_meas = points{t};
    LEN_next = length(next_meas);
    for ii = 1:LEN
        F = trajectory{ii}.F;
        Q = trajectory{ii}.Q;
        R = trajectory{ii}.R;
        H = trajectory{ii}.H;
        X = trajectory{ii}.X;
        P = trajectory{ii}.P;

        X_predict = F * X(:, end);
        P_predict = F * P * F' + Q;
        S = H * P_predict * H' + R;

        Z_estimate = H * X_predict;

        % % 画出波门
        % part_r = 500;
        % left = Z_estimate(1) - part_r;
        % right = Z_estimate(1) + part_r;
        % bottom = Z_estimate(2) - part_r;
        % top = Z_estimate(2) + part_r;
        % contour_x = linspace(left, right, 100);
        % contour_y = linspace(bottom, top, 100);
        % [CX, CY] = meshgrid(contour_x, contour_y);
        % CZ = zeros(size(CX));
        % for cii = 1:length(contour_y)
        %     for cjj = 1:length(contour_x)
        %         cr = [CX(cii, cjj); CY(cii, cjj)];
        %         CZ(cii, cjj) = cr' * S * cr;
        %     end
        % end
        % plot(Z_estimate(1), Z_estimate(2), 'b.', 'markersize', 10);
        % contour(CX, CY, CZ);
        % colorbar;
        % % ======
        % pause;



        all_residual = next_meas - Z_estimate * ones(1, LEN_next);
        d = sum(all_residual' * S .* all_residual', 2)';
        d_ind = find(d <= gamma);
        if isempty(d_ind)
            z_next = Z_estimate;
        else
            [~, min_ind] = min(d);
            z_next = next_meas(:, min_ind);
            trajectory{ii}.ok_num = trajectory{ii}.ok_num + 1;
        end
        K = P_predict * H' * inv(S);
        X_estimate = X_predict + K * (z_next - Z_estimate);
        P_estimate = P_predict - K * H * P_predict;
        trajectory{ii}.X(:, end+1) = X_estimate;
        trajectory{ii}.P = P_estimate;
        trajectory{ii}.R = get_R(z_next, radar_location, sigma_rho, sigma_theta);
    end
end


% 删除ok_num不够的航迹
ii = 1;
while ii < length(trajectory)
    if trajectory{ii}.ok_num < ok_num_thres
        trajectory(ii) = [];
    else
        ii = ii + 1;
    end
end



% 可视化
% figure;
hold on;
grid on;
for ii = 1:length(trajectory)
    plot(trajectory{ii}.X(1, :), trajectory{ii}.X(3, :), 'k-', 'linewidth', 1);
end

xlim([0, scale]); ylim([0, scale]);
