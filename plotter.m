close all; clear; clc;

results = readtable('results.csv');

create_plot(results, 'CompileTime',            'Compilation Time',         'Time (ms)');
create_plot(results, 'KeyGenerationTime',      'Key Generation Time',      'Time (ms)');
create_plot(results, 'EncryptionTime',         'Encryption Time',          'Time (ms)');
create_plot(results, 'ExecutionTime',          'Execution Time',           'Time (ms)');
create_plot(results, 'DecryptionTime',         'Decryption Time',          'Time (ms)');
create_plot(results, 'ReferenceExecutionTime', 'Reference Execution Time', 'Time (ms)');
create_plot(results, 'Mse',                    'MSE',                      'MSE');

function create_plot(res, varname, dispname, ylb)
f = figure;

nodeCounts = unique(res.NodeCount)';
for n = nodeCounts
    pathLength = res{res.NodeCount == n, 'PathLength'};
    y = res{res.NodeCount == n, varname};

    plot(pathLength, y, '-o', 'LineWidth', 1, ...
        'DisplayName', sprintf('NodeCount = %d', n));
    hold on;
end

legend; grid;
title(sprintf('Path Length vs %s', dispname));
xlabel('Path Length');
ylabel(ylb);
saveas(f, sprintf('results/%s.png', varname));
end
