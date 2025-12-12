function total_cost = totalcost(X,D, GG2Bat, SOC, ~, k)
% 输入：
%   D: 数据结构，包含所有参数
%   GG2Bat: 电网到电池的功率矩阵
%   SOC: 电池状态
%   k: 时间索引或其他参数
% 输出：
%   f_handle: 目标函数句柄 f(X)

% 计算总目标函数值

% 验证输入维度
total_vars = D.Ne + 2 * D.Nr;
if length(X) ~= total_vars
    error('变量X维度错误: 期望 %d, 实际 %d', total_vars, length(X));
end

% 1. EV充电成本
C2 = D.minREP.Cost_fun(X(1:D.Ne + D.Nr));

% 2. EV效用（负成本）
U1 = 0;
for i = 1:D.Ne
    U1 = U1 + D.minEV.Utility_fun(X(i));
end

% 3. 居民用电成本和效用
U2 = 0;
C1 = 0;

% 计算每个居民节点的成本和效用
for j = 1:D.Nr
    % 居民用电效用
    U2 = U2 + D.minResident.Utility_fun(...
        X(j + D.Ne), ...                % 居民用电功率
        X(j + D.Ne + D.Nr), ...         % 电池功率
        j, k);                           % 节点和时间索引

    % 居民用电成本
    C1 = C1 + D.minResident.Cost_func(...
        X(j + D.Ne + D.Nr), ...         % 电池功率
        GG2Bat(j), ...                  % 电网到电池功率
        SOC(j));                           % 电池状态
end

% 4. 总目标函数（最小化总成本）
% 注意：效用通常是负成本，所以这里是成本 - 效用
% 但根据您的原公式，可能是成本 + 效用（需根据实际情况调整）
total_cost = C1 + C2 - U1 - U2;

% 可选：添加约束惩罚项
% total_cost = add_constraint_penalty(total_cost, X, D);


end