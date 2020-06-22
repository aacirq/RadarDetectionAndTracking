clear; close all; clc;
for mc_ii = 1:50
    fprintf('NO. %d\n', mc_ii);
    fprintf('generate data\n');
    generate_data2;
    fprintf('NN\n');
    NN_main2;
    fprintf('PDA\n');
    main2;
end