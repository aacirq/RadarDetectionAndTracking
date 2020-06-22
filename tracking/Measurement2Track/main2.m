% clear; close all; clc;
clear;

load data2;

% 可视化轨迹
figure;
hold on;
for t_i = 1:target_num
    plot(target{t_i}.X(1, :), target{t_i}.X(3, :), 'k-', 'linewidth', 1);
    plot(target{t_i}.Z(1, :), target{t_i}.Z(2, :), '.');
end

% ====== 处理 ======
trajectory = {};
for t_i = 1:target_num
    trajectory{t_i}.X = init_X(target{t_i}.Z(:, 1), target{t_i}.Z(:, 2), T);
    trajectory{t_i}.P = init_P(target{t_i}.R, T);
    trajectory{t_i}.Q = target{t_i}.Q;
    trajectory{t_i}.F = target{t_i}.F;
    trajectory{t_i}.R = target{t_i}.R;
    trajectory{t_i}.H = target{t_i}.H;
end

for ii = 3:4
    for t_i = 1:target_num
        F = trajectory{t_i}.F;
        X = trajectory{t_i}.X(:, ii - 1);
        P = trajectory{t_i}.P;
        R = trajectory{t_i}.R;
        H = trajectory{t_i}.H;

        X_predict = F * X;
        P_predict = F * P * F' + Q;

        S = H * P_predict * H' + R;
        K = P_predict * H' * inv(S);
        
        residual = target{t_i}.Z(:, ii) - H * X_predict;
        X_next = X_predict + K * residual;
        P_next = P_predict - K * H * P_predict;
        trajectory{t_i}.X = [trajectory{t_i}.X, X_next];
        trajectory{t_i}.P = P_next;
    end
end

gate_thres = 16.3;
PD = 0.99;
PG = 0.99;
lambda = 0.00004;

for ii = 5:100
    % ii
    for t_i = 1:target_num
        F = trajectory{t_i}.F;
        X = trajectory{t_i}.X(:, ii - 1);
        P = trajectory{t_i}.P;
        R = trajectory{t_i}.R;
        H = trajectory{t_i}.H;

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

        % plot(trajectory{t_i}.X(1, :), trajectory{t_i}.X(3, :), 'r-');
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
            e = e(able_ind);

            b = lambda * sqrt(abs(det(2 * pi * S))) * (1 - PD * PG) / PD;

            beta0 = b / (b + sum(e));
            beta = e ./ (b + sum(e));

            v_k = sum(ones(2, 1) * beta .* all_residual(:, able_ind), 2);

            X_next = X_predict + K * v_k;

            P_c = P_predict - K * H * P_predict;
            part1 = zeros(2);
            for b_ii = 1:length(able_ind)
                this_v = all_residual(:, able_ind(b_ii));
                part1 = part1 + beta(b_ii) * this_v * this_v';
            end
            P_hat = K * (part1 - v_k*v_k') * K';
            P_next = P_predict * beta0 + (1 - beta0) * P_c + P_hat;
        end

        trajectory{t_i}.X(:, end+1) = X_next;
        trajectory{t_i}.P = P_next;
        % pause;
        
        % plot(trajectory{t_i}.X(1, :), trajectory{t_i}.X(3, :), 'r-');
        % pause;
    end
end


% 可视化滤波轨迹
for t_i = 1:target_num
    plot(trajectory{t_i}.X(1, :), trajectory{t_i}.X(3, :), 'r-', 'linewidth', 1);
end
xlim([left, right]);
ylim([bottom, top]);
grid on;