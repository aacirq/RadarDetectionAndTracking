clear; close all; clc;
% ����һ�����ӣ�Ȼ���������㷨����
% CA CFAR, OS CFAR, SOCA CFAR, GOCA CFAR, S-CFAR, Log CFAR
% λ����50��55����Ŀ�꣬50�������10dB��55�������15dB
% ǰ100��Ԫ��������20dB����100��Ԫ��������30dB

num_cell = 200;
Pfa = 10^(-5);

signal1 = generateDataGaussianWhite(100, [50, 55], [35, 40], 20);
signal2 = generateDataGaussianWhite(100, [], [], 30);
signal = [signal1, signal2];
plot(1:num_cell, pow2db(signal), 'k-', 'linewidth', 0.5);
hold on;

% CA CFAR����
[position, threshold, start_cell, stop_cell] = cacfar(signal, Pfa, 10, 2);
plot(start_cell:stop_cell, pow2db(threshold), 'linewidth', 1);
% OS CFAR����
[position, threshold, start_cell, stop_cell] = oscfar(signal, Pfa, 10, 2, 15);
plot(start_cell:stop_cell, pow2db(threshold), 'linewidth', 1);
% SOCA CFAR����
[position, threshold, start_cell, stop_cell] = socacfar(signal, Pfa, 10, 2);
plot(start_cell:stop_cell, pow2db(threshold), 'linewidth', 1);
% GOCA CFAR����
[position, threshold, start_cell, stop_cell] = gocacfar(signal, Pfa, 10, 2);
plot(start_cell:stop_cell, pow2db(threshold), 'linewidth', 1);


grid on;
legend('�ź�', 'CA CFAR��ֵ', 'OS CFAR��ֵ', 'SOCA CFAR��ֵ', 'GOCA CFAR��ֵ');