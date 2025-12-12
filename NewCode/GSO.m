function [Pev,Pbuy,Pbat,Lambda]=GSO(D,GG2BatV,SOCV,SOCV_of_EV,k)
% 定义约束问题：Rosenbrock函数 + 约束
dim = D.Ne+D.Nr+D.Nr;

% 目标函数
f_handle = Allfun(D,GG2BatV,SOCV,SOCV_of_EV,k);% 返回一个关于X的目标函数句柄

% 约束条件（通过罚函数处理） 
constraints = {
    @(x) D.minREP.U_feeder*x(1:D.Nr+D.Ne)'-D.minREP.B_feeder,      % g1(x) ≤ 0 
    };

% 创建带罚函数的目标函数
penalty_objective = @(x) constrained_objective(x, f_handle, constraints);

% 设置边界
lb = zeros(1, dim);
ub = zeros(1, dim);
ub(1:D.Ne)=D.minEV.Pmax_ev;
for j=1:D.Nr
    ub(D.Ne+j)=D.minResident.GC(j,k);
end
for jj=1:D.Nr
    ub(D.Ne+D.Nr+j)=D.minResident.bat_beta*(SOCV(jj)*D.minResident.Capacity_bat+D.minResident.eta*GG2BatV(jj)*D.minResident.Time_int)*D.minResident.eta/D.minResident.Time_int; 
end 

goa = GrasshopperOptimizationAlgorithm(...
    penalty_objective, dim, lb, ub, ...
    'pop_size', 50, ...
    'max_iter', 300);
% 执行优化
[best_solution, best_fitness] = goa.optimize();

% 验证约束
fprintf('\n 目标函数值：%d:\n',best_fitness);
fprintf('\n约束验证:\n'); 
g_val = constraints{1}(best_solution);
for i = 1:length(g_val) 
fprintf('  g%d(x) = %.6f %s\n', i, g_val(i), ...
        iff(g_val(i) <= 0, '✓ 满足', '✗ 违反'));
end
% 查看结果
% goa.display_summary();

% 绘制收敛曲线
% goa.plot_convergence('log_scale', true);

Pev=best_solution(1:D.Ne)';
Pbuy=best_solution(1+D.Ne:D.Ne+D.Nr)';
Pbat=best_solution(1+D.Ne+D.Nr:end)';
Lambda=zeros(D.Nr+D.Ne,1);

end

function f_handle = Allfun(D, GG2Bat, SOC, ~, k)
% 返回一个关于X的目标函数句柄
% 输入：
%   D: 数据结构，包含所有参数
%   GG2Bat: 电网到电池的功率矩阵
%   SOC: 电池状态
%   k: 时间索引或其他参数
% 输出：
%   f_handle: 目标函数句柄 f(X)

% =================== 内部函数定义 ===================
    function total_cost = objective_function(X)
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

% =================== 返回函数句柄 ===================
f_handle = @objective_function;

end

function f = constrained_objective(x, base_obj, constraints)
% 带罚函数的目标函数

% 计算基础目标值
f_base = base_obj(x);

% 计算约束违反度
penalty = 0;
penalty_coefficient = 1e6;
g_val = constraints{1}(x);
for i = 1:length(g_val) 
    if g_val(i) > 0  % 约束违反
        penalty = penalty + penalty_coefficient * g_val(i)^2;
    end
end

f = f_base + penalty;
end
%% ============ 辅助函数 ============
function result = iff(condition, true_value, false_value)
    % 仿效三元运算符
    if condition
        result = true_value;
    else
        result = false_value;
    end
end