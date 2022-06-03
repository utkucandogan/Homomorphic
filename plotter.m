close all; clear; clc;

results = readtable('results.csv');

results.TotalExecutionTime = results.CompileTime + ...
                             results.KeyGenerationTime + ...
                             results.EncryptionTime + ...
                             results.ExecutionTime + ...
                             results.DecryptionTime;

stat = {};
nodeCounts = unique(results.NodeCount)';
for n = nodeCounts
    T = results(results.NodeCount == n,:);  % Select specific node count
    T(:,'SimCnt') = [];                     % Remove SimCnt
    T(:,'NodeCount') = [];                  % Remove NodeCount
    ME = varfun(@mean, T);                  % Mean values
    MI = varfun(@min, T);                   % Minimum values
    MA = varfun(@max, T);                   % Maximum values

    table = [ME, MI, MA];
    table.NodeCount = n;
    stat = [stat; table]; %#ok
end

create_plot(stat, 'CompileTime',            'Compilation Time',         'Time (ms)');
create_plot(stat, 'KeyGenerationTime',      'Key Generation Time',      'Time (ms)');
create_plot(stat, 'EncryptionTime',         'Encryption Time',          'Time (ms)');
create_plot(stat, 'ExecutionTime',          'Execution Time',           'Time (ms)');
create_plot(stat, 'DecryptionTime',         'Decryption Time',          'Time (ms)');
create_plot(stat, 'TotalExecutionTime',     'Total Execution Time',     'Time (ms)');
create_plot(stat, 'ReferenceExecutionTime', 'Reference Execution Time', 'Time (ms)');
create_plot(stat, 'Mse',                    'MSE',                      'MSE');

f = figure;
draw_graph(stat, 'CompileTime',            'Compilation Time',         'Time (ms)');
hold on;
draw_graph(stat, 'KeyGenerationTime',      'Key Generation Time',      'Time (ms)');
draw_graph(stat, 'EncryptionTime',         'Encryption Time',          'Time (ms)');
draw_graph(stat, 'ExecutionTime',          'Execution Time',           'Time (ms)');
draw_graph(stat, 'DecryptionTime',         'Decryption Time',          'Time (ms)');

legend('Location', 'northwest'); grid;
title(sprintf('Node Count vs Individual Times'));
saveas(f, 'results/IndTimes.png');

f = figure;
draw_graph(stat, 'TotalExecutionTime',     'Total Execution Time',     'Time (ms)');
hold on;
draw_graph(stat, 'ReferenceExecutionTime', 'Reference Execution Time', 'Time (ms)');

legend('Location', 'northwest'); grid;
title(sprintf('Node Count vs Total Times'));
saveas(f, 'results/TotalTimes.png');

function draw_graph(stat, varname, dispname, ylb)
    nodeCounts = stat.NodeCount;
    means = stat{:, strcat('mean_', varname)};
    mins  = stat{:, strcat('min_', varname)};
    maxs  = stat{:, strcat('max_', varname)};

    neg = means - mins;
    pos = maxs - means;

    errorbar(nodeCounts, means, neg, pos, '-o', 'LineWidth', 1, ...
        'DisplayName', dispname);

    xlabel('Node Count');
    ylabel(ylb);
end

function create_plot(stat, varname, dispname, ylb)
    f = figure;
    
    draw_graph(stat, varname, dispname, ylb)
    
    grid;
    title(sprintf('Node Count vs %s', dispname));
    xlabel('Node Count');
    ylabel(ylb);
    saveas(f, sprintf('results/%s.png', varname));
end
