clear; close all; clc;
% ====== 显示波门 ==============================================================

% % 环形波门
% V_max = 10;
% V_min = 5;
% T = 1;

% x0 = [0; 0];
% x = linspace(-15, 15, 100);
% y = linspace(-15, 15, 100);
% [X, Y] = meshgrid(x, y);
% Z = zeros(size(X));

% for ii = 1:length(x)
%     for jj = 1:length(y)
%         this_x = [X(jj, ii); Y(jj, ii)];
%         Z(jj, ii) = sqrt(sum((this_x - x0) .^ 2));
%     end
% end

% figure;
% min_distance = V_min * T;
% max_distance = V_max * T;
% contour(X, Y, Z, [min_distance, min_distance]);
% hold on;
% contour(X, Y, Z, [max_distance, max_distance])
% axis square;

% ==============================================================================
% 椭圆波门
S = [1, 1; 0, 1];
x0 = [0; 0];
x = linspace(-10, 10, 100);
y = linspace(-10, 10, 100);
[X, Y] = meshgrid(x, y);
Z = zeros(size(X));

for jj = 1:length(y)
    for ii = 1:length(x)
        z = [X(ii, jj); Y(ii, jj)];
        Z(ii, jj) = z' * inv(S) * z;
    end
end

threshold = 25;
contour(X, Y, Z, [threshold, threshold], 'linewidth', 2);
grid on;
axis square;