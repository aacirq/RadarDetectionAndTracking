clear; close all; clc;

for mc_ii = 1:50
    fprintf('NO. %d\n', mc_ii);
    fprintf('generate data\n');
    generate_data;
    fprintf('NN\n');
    NN_main;
    fprintf('PDA\n');
    main;
end