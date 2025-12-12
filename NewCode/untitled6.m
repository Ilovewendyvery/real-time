% % 定义目标函数
% obj_func = @(x) sum(x.^2);  % Sphere函数
% 
% % 设置参数
% dim = 50;
% lb = -100 * ones(1, dim);
% ub = 100 * ones(1, dim);
% 
% % 创建GOA实例
% goa = GrasshopperOptimizationAlgorithm(obj_func, dim, lb, ub, ...
%     'pop_size', 50, ...
%     'max_iter', 200, ...
%     'use_high_dim_strategy', true);
% 
% % 执行优化
% [best_solution, best_fitness] = goa.optimize();
% 
% % 查看结果
% goa.display_summary();
% 
% % 绘制收敛曲线
% goa.plot_convergence('log_scale', true);
% 
% % 保存结果
% goa.save_results();
% 
% 
% 
%% ============ 测试函数定义 ============
function f = sphere_function(x)
    % Sphere测试函数
    f = sum(x.^2);
end

function f = rastrigin_function(x)
    % Rastrigin测试函数
    n = length(x);
    f = 10*n + sum(x.^2 - 10*cos(2*pi*x));
end

function f = ackley_function(x)
    % Ackley测试函数
    n = length(x);
    sum1 = sum(x.^2);
    sum2 = sum(cos(2*pi*x));
    f = -20*exp(-0.2*sqrt(sum1/n)) - exp(sum2/n) + 20 + exp(1);
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

%% ============ 主测试程序 ============
function main_test()
    % GOA主测试程序
    
    clear; clc; close all;
    
    fprintf('草蜢优化算法(GOA)测试程序\n');
    fprintf('=========================\n\n');
    
    % ============ 测试配置 ============
    test_cases = {
        {'低维测试', 10, @sphere_function},    % 案例1: 低维Sphere
        {'中维测试', 50, @rastrigin_function}, % 案例2: 中维Rastrigin
        {'高维测试', 200, @ackley_function}    % 案例3: 高维Ackley
    };
    
    % ============ 运行测试 ============
    for case_idx = 1:length(test_cases)
        case_name = test_cases{case_idx}{1};
        dim = test_cases{case_idx}{2};
        obj_func = test_cases{case_idx}{3};
        
        fprintf('\n测试案例 %d: %s (维度=%d)\n', case_idx, case_name, dim);
        fprintf('================================\n');
        
        % 设置边界
        if strcmp(func2str(obj_func), 'sphere_function')
            lb = -100 * ones(1, dim);
            ub = 100 * ones(1, dim);
        else
            lb = -5.12 * ones(1, dim);
            ub = 5.12 * ones(1, dim);
        end
        
        % 确定是否使用高维策略
        use_high_dim = dim > 100;
        
        % 创建GOA实例
        goa = GrasshopperOptimizationAlgorithm(...
            obj_func, dim, lb, ub, ...
            'pop_size', 50, ...
            'max_iter', 200, ...
            'use_high_dim_strategy', use_high_dim, ...
            'reduction_type', 'adaptive');
        
        % 执行优化
        [best_solution, best_fitness] = goa.optimize();
        
        % 显示结果
        goa.display_summary();
        
        % 绘制收敛曲线
        goa.plot_convergence('figure_num', case_idx, 'log_scale', true);
        
        % 绘制种群分布（仅对低维案例）
        if dim <= 3
            goa.plot_population_distribution(case_idx + 10);
        end
        
        % 保存结果
        goa.save_results(sprintf('GOA_%s_dim%d.mat', case_name, dim));
        
        fprintf('\n');
    end
    
    fprintf('所有测试完成!\n');
end

%% ============ 高级功能示例：处理约束问题 ============
function constrained_optimization_example()
    % 约束优化问题示例
    
    fprintf('\n约束优化问题示例\n');
    fprintf('=================\n');
    
    % 定义约束问题：Rosenbrock函数 + 约束
    dim = 10;
    
    % 目标函数
    objective = @(x) 100*(x(2) - x(1)^2)^2 + (1 - x(1))^2-2000;
    
    % 约束条件（通过罚函数处理）
    constraints = {
        @(x) x(1)^2 + x(2)^2 - 1,      % g1(x) ≤ 0
        @(x) x(1) + x(2) - 1.5,        % g2(x) ≤ 0
        @(x) x(3) - 0.5                % g3(x) ≤ 0
    };
    
    % 创建带罚函数的目标函数
    penalty_objective = @(x) constrained_objective(x, objective, constraints);
    
    % 设置边界
    lb = -2 * ones(1, dim);
    ub = 2 * ones(1, dim);
    
    % 创建GOA实例
    goa = GrasshopperOptimizationAlgorithm(...
        penalty_objective, dim, lb, ub, ...
        'pop_size', 40, ...
        'max_iter', 300);
    
    % 执行优化
    [best_solution, best_fitness] = goa.optimize();
    
    % 验证约束
    fprintf('\n约束验证:\n');
    for i = 1:length(constraints)
        g_val = constraints{i}(best_solution);
        fprintf('  g%d(x) = %.6f %s\n', i, g_val, ...
            iff(g_val <= 0, '✓ 满足', '✗ 违反'));
    end
    goa.display_summary();

    % 绘制收敛曲线
    goa.plot_convergence('log_scale', true);
end

function f = constrained_objective(x, base_obj, constraints)
    % 带罚函数的目标函数
    
    % 计算基础目标值
    f_base = base_obj(x);
    
    % 计算约束违反度
    penalty = 0;
    penalty_coefficient = 1e6;
    
    for i = 1:length(constraints)
        g_val = constraints{i}(x);
        if g_val > 0  % 约束违反
            penalty = penalty + penalty_coefficient * g_val^2;
        end
    end
    
    f = f_base + penalty;
end

%% ============ 运行主程序 ============
% 取消下面的注释以运行测试

 % main_test();  % 运行主测试程序
 constrained_optimization_example();  % 运行约束优化示例