% clear; close all; clc;
clear;

load data;

% 可视化轨迹
figure;
hold on;
plot(target{1}.X(1, :), target{1}.X(3, :), 'k-', 'linewidth', 1, 'displayname', '实际轨迹');
plot(target{1}.Z(1, :), target{1}.Z(2, :), '.', 'displayname', '目标量测值');

% ====== 处理 ======
trajectory = {};
trajectory{1}.X = init_X(target{1}.Z(:, 1), target{1}.Z(:, 2), T);
trajectory{1}.P = init_P(target{1}.R, T);
trajectory{1}.Q = target{1}.Q;
trajectory{1}.F = target{1}.F;
trajectory{1}.R = target{1}.R;
trajectory{1}.H = target{1}.H;

for ii = 3:4
    F = trajectory{1}.F;
    X = trajectory{1}.X(:, ii - 1);
    P = trajectory{1}.P;
    R = trajectory{1}.R;
    H = trajectory{1}.H;

    X_predict = F * X;
    P_predict = F * P * F' + Q;

    S = H * P_predict * H' + R;
    K = P_predict * H' * inv(S);
    
    residual = target{1}.Z(:, ii) - H * X_predict;
    X_next = X_predict + K * residual;
    P_next = P_predict - K * H * P_predict;
    trajectory{1}.X = [trajectory{1}.X, X_next];
    trajectory{1}.P = P_next;

end

gate_thres = 16.3;
PD = 0.99;
PG = 0.99;
lambda = 0.00004;

for ii = 5:100
    F = trajectory{1}.F;
    X = trajectory{1}.X(:, ii - 1);
    P = trajectory{1}.P;
    R = trajectory{1}.R;
    H = trajectory{1}.H;

    X_predict = F * X;
    P_predict = F * P * F' + Q;
    % pause;
    S = H * P_predict * H' + R;
    K = P_predict * H' * inv(S);

    % % 画波门
    % x = linspace(X_predict(1) - 50, X_predict(1) + 50, 100);
    % y = linspace(X_predict(3) - 50, X_predict(3) + 50, 100);
    % [X, Y] = meshgrid(x, y);
    % Z = zeros(size(X));
    % for c_ii = 1:length(y)
    %     for c_jj = 1:length(x)
    %         z = [X(c_ii, c_jj); Y(c_ii, c_jj)];
    %         res = z - H * X_predict;
    %         Z(c_ii, c_jj) = res' * inv(S) * res;
    %     end
    % end
    % contour(X, Y, Z);
    % % contour(X, Y, Z, [gate_thres, gate_thres]);
    % colorbar();

    % plot(trajectory{1}.X(1, :), trajectory{1}.X(3, :), 'r-');
    % plot(measurement{ii}(1, :), measurement{ii}(2, :), 'k.');

    % pause;
    % ======

    next_meas = measurement{ii};
    all_residual = next_meas - H * X_predict * ones(1, length(next_meas));
    e = zeros(1, length(next_meas));
    dist = zeros(1, length(next_meas));
    for e_i = 1:length(next_meas)
        v = all_residual(:, e_i);
        dist(e_i) = v' * inv(S) * v;
        e(e_i) = exp(-0.5 * v' * inv(S) * v);
    end
    able_ind = find(dist < gate_thres);
    % length(able_ind)

    if isempty(able_ind)
        X_next = X_predict;
        P_next = P_predict;
    else
        [~, min_ind] = min(dist(1, able_ind));

        Z = next_meas(:, able_ind(min_ind));
        X_next = X_predict + K * (Z - H * X_predict);
        P_next = P_predict - K * H * P_predict;
    end

    trajectory{1}.X(:, end+1) = X_next;
    trajectory{1}.P = P_next;
    % pause;
    
    % plot(trajectory{1}.X(1, :), trajectory{1}.X(3, :), 'r-');
    % pause;
end


% 可视化滤波轨迹
plot(trajectory{1}.X(1, :), trajectory{1}.X(3, :), 'r-', 'linewidth', 1, 'DisplayName', '跟踪轨迹');
xlim([left, right]);
ylim([bottom, top]);
legend;
grid on;