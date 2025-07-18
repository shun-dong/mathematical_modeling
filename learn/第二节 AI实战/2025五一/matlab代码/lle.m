%% 3. 局部线性嵌入（LLE）降维
function [Y] = lle(X, M, k)
    % 输入：X是原始数据，M是每个点的邻居数，k是目标维度
    % 输出：Y是降维后的数据

    % 计算样本点之间的欧几里得距离
    n = size(X, 1); % 样本数
    dist = pdist2(X, X);  % 计算所有点之间的欧几里得距离
    [~, idx] = sort(dist, 2); % 对每一行（样本）排序

    % 选择最近的 M 个邻居
    W = zeros(n, n);  % 邻接矩阵
    for i = 1:n
        neighbors = idx(i, 2:M+1);  % 获取每个点的 M 个邻居
        % 计算重构权重（W矩阵）
        Z = X(neighbors, :) - repmat(X(i, :), M, 1);  % 数据点与邻居的差
        C = Z * Z';  % 计算协方差矩阵
        C_inv = pinv(C);  % 计算协方差矩阵的伪逆
        w = C_inv * ones(M, 1);  % 计算权重
        w = w / sum(w);  % 正则化权重
        W(i, neighbors) = w';  % 更新邻接矩阵
    end
        % 求解低维嵌入
    M = eye(n) - W;  % 计算（I - W）矩阵
    [V, D] = eig(M' * M);  % 特征值分解
    [~, idx] = sort(diag(D));  % 排序特征值
    Y = V(:, idx(2:k+1));  % 选择对应的特征向量（忽略第一个最小的特征值）
end