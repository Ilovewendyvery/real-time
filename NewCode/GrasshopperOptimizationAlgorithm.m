%% 草蜢优化算法 (Grasshopper Optimization Algorithm) MATLAB 类实现
% 作者：DeepSeek
% 版本：1.0
% 功能：解决高维优化问题
% 参考文献：Saremi, S., Mirjalili, S., & Lewis, A. (2017). 
%           Grasshopper Optimisation Algorithm: Theory and application.

classdef GrasshopperOptimizationAlgorithm < handle
    % 草蜢优化算法类
    
    properties
        % ============ 算法参数 ============
        obj_func             % 目标函数句柄
        dim                  % 问题维度
        lb                   % 变量下界 (1×dim)
        ub                   % 变量上界 (1×dim)
        pop_size             % 种群大小
        max_iter             % 最大迭代次数
        
        % ============ 算法控制参数 ============
        c_min                % 最小舒适度系数
        c_max                % 最大舒适度系数
        reduction_type       % c值递减类型：'linear'或'adaptive'
        
        % ============ 种群信息 ============
        population           % 种群位置 (pop_size × dim)
        fitness              % 适应度值 (pop_size × 1)
        personal_best        % 个体历史最佳位置
        personal_best_fitness % 个体历史最佳适应度
        
        % ============ 全局信息 ============
        global_best          % 全局最佳位置 (1×dim)
        global_best_fitness  % 全局最佳适应度
        convergence_curve    % 收敛曲线 (max_iter × 1)
        
        % ============ 高维优化参数 ============
        use_high_dim_strategy % 是否使用高维策略
        group_size           % 分组大小（用于高维）
        
        % ============ 统计信息 ============
        execution_time       % 执行时间
        iteration_info       % 迭代信息存储
    end
    
    methods
        %% ============ 构造函数 ============
        function obj = GrasshopperOptimizationAlgorithm(obj_func, dim, lb, ub, varargin)
            % 构造函数
            % 输入：
            %   obj_func: 目标函数句柄
            %   dim: 问题维度
            %   lb: 变量下界 (1×dim 或标量)
            %   ub: 变量上界 (1×dim 或标量)
            %   varargin: 可选参数，见 parse_parameters 方法
            
            obj.obj_func = obj_func;
            obj.dim = dim;
            
            % 处理边界
            if isscalar(lb)
                obj.lb = lb * ones(1, dim);
            else
                obj.lb = lb;
            end
            
            if isscalar(ub)
                obj.ub = ub * ones(1, dim);
            else
                obj.ub = ub;
            end
            
            % 解析可选参数
            obj.parse_parameters(varargin{:});
            
            % 初始化算法
            obj.initialize();
        end
        
        %% ============ 参数解析 ============
        function parse_parameters(obj, varargin)
            % 解析可选参数
            
            p = inputParser;
            addParameter(p, 'pop_size', 30, @(x) isnumeric(x) && x > 0);
            addParameter(p, 'max_iter', 500, @(x) isnumeric(x) && x > 0);
            addParameter(p, 'c_min', 0.00004, @isnumeric);
            addParameter(p, 'c_max', 1.0, @isnumeric);
            addParameter(p, 'reduction_type', 'linear', @ischar);
            addParameter(p, 'use_high_dim_strategy', false, @islogical);
            addParameter(p, 'group_size', 20, @isnumeric);
            
            parse(p, varargin{:});
            
            obj.pop_size = p.Results.pop_size;
            obj.max_iter = p.Results.max_iter;
            obj.c_min = p.Results.c_min;
            obj.c_max = p.Results.c_max;
            obj.reduction_type = p.Results.reduction_type;
            obj.use_high_dim_strategy = p.Results.use_high_dim_strategy;
            obj.group_size = p.Results.group_size;
        end
        
        %% ============ 初始化 ============
        function initialize(obj)
            % 初始化种群和算法参数
            
            fprintf('初始化草蜢优化算法...\n');
            fprintf('维度: %d, 种群大小: %d, 最大迭代: %d\n', ...
                    obj.dim, obj.pop_size, obj.max_iter);
            
            % 初始化种群（均匀分布）
            obj.population = zeros(obj.pop_size, obj.dim);
            for i = 1:obj.pop_size
                obj.population(i, :) = obj.lb + (obj.ub - obj.lb) .* rand(1, obj.dim);
            end
            
            % 计算初始适应度
            obj.fitness = zeros(obj.pop_size, 1);
            for i = 1:obj.pop_size
                obj.fitness(i) = obj.evaluate(obj.population(i, :));
            end
            
            % 初始化个体历史最佳
            obj.personal_best = obj.population;
            obj.personal_best_fitness = obj.fitness;
            
            % 初始化全局最佳
            [obj.global_best_fitness, best_idx] = min(obj.fitness);
            obj.global_best = obj.population(best_idx, :);
            
            % 初始化收敛曲线
            obj.convergence_curve = zeros(obj.max_iter, 1);
            
            % 初始化迭代信息
            obj.iteration_info = struct();
            
            fprintf('初始化完成.\n');
        end
        
        %% ============ 评估函数 ============
        function fitness_value = evaluate(obj, position)
            % 评估个体适应度
            % 输入：
            %   position: 个体位置 (1×dim)
            % 输出：
            %   fitness_value: 适应度值
            
            % 边界检查
            position = max(position, obj.lb);
            position = min(position, obj.ub);
            
            % 计算适应度
            fitness_value = obj.obj_func(position);
        end
        
        %% ============ 计算舒适度系数c ============
        function c = calculate_c(obj, iteration)
            % 计算当前迭代的舒适度系数c
            % c控制探索与开发的平衡
            
            switch obj.reduction_type
                case 'linear'
                    % 线性递减
                    c = obj.c_max - iteration * (obj.c_max - obj.c_min) / obj.max_iter;
                    
                case 'adaptive'
                    % 自适应递减（考虑维度）
                    t = iteration / obj.max_iter;
                    dim_factor = log10(obj.dim) / 3;  % 维度因子
                    c = obj.c_max * exp(-4 * t * (1 + dim_factor));
                    c = max(c, obj.c_min);
                    
                case 'nonlinear'
                    % 非线性递减
                    t = iteration / obj.max_iter;
                    c = obj.c_max * cos((pi/2) * t) + obj.c_min;
                    
                otherwise
                    % 默认线性递减
                    c = obj.c_max - iteration * (obj.c_max - obj.c_min) / obj.max_iter;
            end
            
            % 确保c在合理范围内
            c = max(c, obj.c_min);
            c = min(c, obj.c_max);
        end
        
        %% ============ 计算社会力函数s ============
        function s = social_function(obj, r)
            % 计算社会力函数s(r)
            % s(r) = f * exp(-r/l) - exp(-r)
            % 其中：f = 0.5, l = 1.5 (默认值)
            
            f = 0.5;  % 吸引力强度
            l = 1.5;  % 吸引力尺度
            
            % 计算社会力
            s = f * exp(-r/l) - exp(-r);
            
            % 限制值域
            s = min(max(s, -1), 1);
        end
        
        %% ============ 计算引力分量 ============
        function gravity = calculate_gravity(obj, position, c)
            % 计算引力分量（向全局最优移动）
            gravity = c * (obj.global_best - position) / 2;
        end
        
        %% ============ 计算社会力分量 ============
        function social_force = calculate_social_force(obj, position, idx, c)
            % 计算社会力分量（与其他草蜢的交互）
            
            social_force = zeros(1, obj.dim);
            
            for j = 1:obj.pop_size
                if j ~= idx
                    % 计算距离
                    distance = norm(obj.population(j, :) - position);
                    
                    if distance > 0  % 避免除以零
                        % 标准化距离
                        normalized_distance = distance / (obj.ub(1) - obj.lb(1));
                        
                        % 计算社会力
                        s_val = obj.social_function(normalized_distance);
                        
                        % 计算方向向量
                        direction = (obj.population(j, :) - position) / (distance + eps);
                        
                        % 累加社会力
                        social_force = social_force + s_val * direction;
                    end
                end
            end
            
            % 应用舒适度系数
            social_force = c * social_force;
        end
        
        %% ============ 高维策略：分组优化 ============
        function update_with_grouping(obj, c, iteration)
            % 高维问题的分组优化策略
            
            % 确定分组数量
            num_groups = ceil(obj.dim / obj.group_size);
            
            for group = 1:num_groups
                % 确定当前组的维度范围
                start_dim = (group-1) * obj.group_size + 1;
                end_dim = min(group * obj.group_size, obj.dim);
                group_dims = start_dim:end_dim;
                
                % 对当前组进行优化
                obj.optimize_dimension_group(group_dims, c);
            end
            
            % 定期进行组间信息交换
            if mod(iteration, 10) == 0
                obj.exchange_between_groups();
            end
        end
        
        %% ============ 优化指定维度组 ============
        function optimize_dimension_group(obj, dims, c)
            % 优化指定的维度组
            
            group_size = length(dims);
            
            % 创建子问题种群
            sub_population = obj.population(:, dims);
            
            % 计算子问题的全局最优
            sub_global_best = obj.global_best(dims);
            
            % 更新子种群
            for i = 1:obj.pop_size
                % 计算引力
                gravity = c * (sub_global_best - sub_population(i, :)) / 2;
                
                % 计算社会力（只在组内维度）
                social_force = zeros(1, group_size);
                for j = 1:obj.pop_size
                    if j ~= i
                        distance = norm(sub_population(j, :) - sub_population(i, :));
                        if distance > 0
                            s_val = obj.social_function(distance/(obj.ub(1)-obj.lb(1)));
                            direction = (sub_population(j, :) - sub_population(i, :)) / (distance + eps);
                            social_force = social_force + s_val * direction;
                        end
                    end
                end
                social_force = c * social_force;
                
                % 随机探索分量
                exploration = randn(1, group_size) * 0.1 * c;
                
                % 更新位置
                new_position = social_force + gravity + exploration;
                
                % 边界处理
                new_position = max(new_position, obj.lb(dims));
                new_position = min(new_position, obj.ub(dims));
                
                % 更新主种群
                obj.population(i, dims) = new_position;
            end
        end
        
        %% ============ 组间信息交换 ============
        function exchange_between_groups(obj)
            % 在不同维度组间交换信息
            
            if obj.dim <= obj.group_size
                return;  % 不需要分组交换
            end
            
            num_groups = ceil(obj.dim / obj.group_size);
            
            % 随机选择两个组进行交换
            group1 = randi(num_groups);
            group2 = randi(num_groups);
            while group2 == group1
                group2 = randi(num_groups);
            end
            
            % 交换部分个体的维度信息
            exchange_ratio = 0.2;  % 交换比例
            num_exchange = ceil(obj.pop_size * exchange_ratio);
            exchange_indices = randperm(obj.pop_size, num_exchange);
            
            for idx = exchange_indices
                % 获取两个组的维度范围
                start1 = (group1-1)*obj.group_size + 1;
                end1 = min(group1*obj.group_size, obj.dim);
                
                start2 = (group2-1)*obj.group_size + 1;
                end2 = min(group2*obj.group_size, obj.dim);
                
                % 交换维度值
                temp = obj.population(idx, start1:end1);
                obj.population(idx, start1:end1) = obj.population(idx, start2:end2);
                obj.population(idx, start2:end2) = temp;
            end
        end
        
        %% ============ 标准位置更新 ============
        function update_positions_standard(obj, c)
            % 标准GOA位置更新
            
            new_population = zeros(size(obj.population));
            
            for i = 1:obj.pop_size
                % 计算社会力
                social_force = obj.calculate_social_force(obj.population(i, :), i, c);
                
                % 计算引力
                gravity = obj.calculate_gravity(obj.population(i, :), c);
                
                % 计算探索分量（随机扰动）
                exploration = (obj.ub - obj.lb) .* (rand(1, obj.dim) - 0.5) * 0.1 * c;
                
                % 更新位置
                new_position = social_force + gravity + exploration;
                
                % 边界处理
                new_position = max(new_position, obj.lb);
                new_position = min(new_position, obj.ub);
                
                new_population(i, :) = new_position;
            end
            
            obj.population = new_population;
        end
        
        %% ============ 更新种群 ============
        function update_population(obj)
            % 评估新种群并更新最佳解
            
            for i = 1:obj.pop_size
                % 计算适应度
                new_fitness = obj.evaluate(obj.population(i, :));
                
                % 更新个体历史最佳
                if new_fitness < obj.personal_best_fitness(i)
                    obj.personal_best(i, :) = obj.population(i, :);
                    obj.personal_best_fitness(i) = new_fitness;
                end
                
                % 更新适应度
                obj.fitness(i) = new_fitness;
                
                % 更新全局最佳
                if new_fitness < obj.global_best_fitness
                    obj.global_best = obj.population(i, :);
                    obj.global_best_fitness = new_fitness;
                end
            end
        end
        
        %% ============ 主优化函数 ============
        function [best_solution, best_fitness] = optimize(obj)
            % 执行GOA优化
            % 输出：
            %   best_solution: 最优解
            %   best_fitness: 最优适应度值
            
            fprintf('\n开始草蜢优化算法...\n');
            fprintf('使用策略: %s\n', ...
                iff(obj.use_high_dim_strategy && obj.dim > 100, '高维分组优化', '标准优化'));
            
            start_time = tic;
            
            % 主优化循环
            for iter = 1:obj.max_iter
                % 计算当前迭代的舒适度系数c
                c = obj.calculate_c(iter);
                
                % 选择更新策略
                if obj.use_high_dim_strategy && obj.dim > 100
                    % 高维策略：分组优化
                    obj.update_with_grouping(c, iter);
                else
                    % 标准策略
                    obj.update_positions_standard(c);
                end
                
                % 更新种群适应度和最佳解
                obj.update_population();
                
                % 记录收敛曲线
                obj.convergence_curve(iter) = obj.global_best_fitness;
                
                % 记录迭代信息
                obj.record_iteration_info(iter, c);
                
                % 显示进度
                if mod(iter, 50) == 0 || iter == 1 || iter == obj.max_iter
                    obj.display_progress(iter, c);
                end
            end
            
            % 记录执行时间
            obj.execution_time = toc(start_time);
            
            % 输出最终结果
            fprintf('\n优化完成!\n');
            fprintf('执行时间: %.2f 秒\n', obj.execution_time);
            fprintf('最终适应度: %.6e\n', obj.global_best_fitness);
            
            % 返回结果
            best_solution = obj.global_best;
            best_fitness = obj.global_best_fitness;
        end
        
        %% ============ 记录迭代信息 ============
        function record_iteration_info(obj, iteration, c)
            % 记录每次迭代的详细信息
            
            obj.iteration_info(iteration).iteration = iteration;
            obj.iteration_info(iteration).c_value = c;
            obj.iteration_info(iteration).best_fitness = obj.global_best_fitness;
            obj.iteration_info(iteration).avg_fitness = mean(obj.fitness);
            obj.iteration_info(iteration).std_fitness = std(obj.fitness);
            
            % 计算种群多样性
            diversity = obj.calculate_population_diversity();
            obj.iteration_info(iteration).diversity = diversity;
        end
        
        %% ============ 计算种群多样性 ============
        function diversity = calculate_population_diversity(obj)
            % 计算种群多样性（平均距离）
            
            mean_position = mean(obj.population, 1);
            distances = zeros(obj.pop_size, 1);
            
            for i = 1:obj.pop_size
                distances(i) = norm(obj.population(i, :) - mean_position);
            end
            
            diversity = mean(distances);
        end
        
        %% ============ 显示进度 ============
        function display_progress(obj, iteration, c)
            % 显示优化进度
            
            % 计算可行解比例（假设没有约束）
            feasible_ratio = 1.0;  % 对于无约束问题
            
            fprintf('迭代 %4d/%d: c=%.4f, 最佳适应度=%.6e, 平均适应度=%.6e\n', ...
                    iteration, obj.max_iter, c, ...
                    obj.global_best_fitness, mean(obj.fitness));
        end
        
        %% ============ 绘制收敛曲线 ============
        function plot_convergence(obj, varargin)
            % 绘制收敛曲线
            % 可选参数：
            %   'figure_num': 图号
            %   'log_scale': 是否使用对数坐标
            
            p = inputParser;
            addParameter(p, 'figure_num', 1, @isnumeric);
            addParameter(p, 'log_scale', false, @islogical);
            addParameter(p, 'show_diversity', false, @islogical);
            parse(p, varargin{:});
            
            figure(p.Results.figure_num);
            clf;
            
            if p.Results.show_diversity && ~isempty(obj.iteration_info)
                % 绘制双Y轴图：适应度和多样性
                yyaxis left;
                plot(1:obj.max_iter, obj.convergence_curve, 'b-', 'LineWidth', 2);
                ylabel('适应度值', 'FontSize', 12);
                
                yyaxis right;
                diversity = arrayfun(@(x) x.diversity, obj.iteration_info);
                plot(1:obj.max_iter, diversity, 'r--', 'LineWidth', 1.5);
                ylabel('种群多样性', 'FontSize', 12);
                
                legend({'适应度', '多样性'}, 'FontSize', 10);
                title('收敛曲线与种群多样性', 'FontSize', 14);
            else
                % 仅绘制收敛曲线
                plot(1:obj.max_iter, obj.convergence_curve, 'b-', 'LineWidth', 2);
                ylabel('适应度值', 'FontSize', 12);
                title('GOA收敛曲线', 'FontSize', 14);
                
                if p.Results.log_scale
                    set(gca, 'YScale', 'log');
                    ylabel('适应度值（对数）', 'FontSize', 12);
                end
            end
            
            xlabel('迭代次数', 'FontSize', 12);
            grid on;
            
            % 添加统计信息文本
            info_str = sprintf('维度: %d\n种群: %d\n最优值: %.4e\n时间: %.2fs', ...
                              obj.dim, obj.pop_size, ...
                              obj.global_best_fitness, obj.execution_time);
            annotation('textbox', [0.15, 0.7, 0.2, 0.15], ...
                      'String', info_str, ...
                      'FontSize', 9, ...
                      'BackgroundColor', 'white', ...
                      'EdgeColor', 'black');
        end
        
        %% ============ 绘制种群分布 ============
        function plot_population_distribution(obj, figure_num)
            % 绘制种群分布
            
            if nargin < 2
                figure_num = 2;
            end
            
            figure(figure_num);
            clf;
            
            if obj.dim >= 2
                % 2D散点图（显示前两个维度）
                subplot(1,2,1);
                scatter(obj.population(:,1), obj.population(:,2), 50, 'filled');
                hold on;
                scatter(obj.global_best(1), obj.global_best(2), 100, 'r', 'filled', '^');
                xlabel('x_1', 'FontSize', 12);
                ylabel('x_2', 'FontSize', 12);
                title('种群分布（最后一代）', 'FontSize', 14);
                legend({'种群个体', '最优解'}, 'Location', 'best');
                grid on;
                hold off;
                
                % 3D散点图（如果维度≥3）
                if obj.dim >= 3
                    subplot(1,2,2);
                    scatter3(obj.population(:,1), obj.population(:,2), ...
                            obj.population(:,3), 50, 'filled');
                    hold on;
                    scatter3(obj.global_best(1), obj.global_best(2), ...
                            obj.global_best(3), 100, 'r', 'filled', '^');
                    xlabel('x_1', 'FontSize', 12);
                    ylabel('x_2', 'FontSize', 12);
                    zlabel('x_3', 'FontSize', 12);
                    title('3D种群分布', 'FontSize', 14);
                    grid on;
                    hold off;
                end
            else
                % 1D直方图
                histogram(obj.population, 20);
                xlabel('变量值', 'FontSize', 12);
                ylabel('频数', 'FontSize', 12);
                title('种群分布直方图', 'FontSize', 14);
                grid on;
            end
        end
        
        %% ============ 参数敏感性分析 ============
        function sensitivity_analysis(obj, param_ranges)
            % 参数敏感性分析
            % param_ranges: 参数范围结构体
            
            if nargin < 2
                param_ranges.pop_size = [20, 30, 40, 50];
                param_ranges.c_max = [0.5, 1.0, 1.5, 2.0];
                param_ranges.c_min = [1e-5, 1e-4, 1e-3];
            end
            
            fprintf('\n参数敏感性分析...\n');
            
            % 测试不同参数组合
            results = [];
            counter = 1;
            
            for pop = param_ranges.pop_size
                for cmax = param_ranges.c_max
                    for cmin = param_ranges.c_min
                        fprintf('测试组合 %d: pop_size=%d, c_max=%.2f, c_min=%.1e\n', ...
                                counter, pop, cmax, cmin);
                        
                        % 创建新GOA实例
                        test_goa = GrasshopperOptimizationAlgorithm(...
                            obj.obj_func, obj.dim, obj.lb, obj.ub, ...
                            'pop_size', pop, ...
                            'c_max', cmax, ...
                            'c_min', cmin, ...
                            'max_iter', 100);  % 快速测试
                        
                        % 运行优化
                        [~, best_fit] = test_goa.optimize();
                        
                        % 存储结果
                        results(counter).pop_size = pop;
                        results(counter).c_max = cmax;
                        results(counter).c_min = cmin;
                        results(counter).best_fitness = best_fit;
                        
                        counter = counter + 1;
                    end
                end
            end
            
            % 绘制敏感性分析结果
            obj.plot_sensitivity_results(results);
        end
        
        %% ============ 绘制敏感性分析结果 ============
        function plot_sensitivity_results(obj, results)
            % 绘制参数敏感性分析结果
            
            figure('Position', [100, 100, 1200, 400]);
            
            % 提取数据
            pop_sizes = [results.pop_size];
            c_maxs = [results.c_max];
            c_mins = [results.c_min];
            fitnesses = [results.best_fitness];
            
            % 子图1: 种群大小影响
            subplot(1,3,1);
            unique_pops = unique(pop_sizes);
            mean_fitness = zeros(size(unique_pops));
            for i = 1:length(unique_pops)
                idx = pop_sizes == unique_pops(i);
                mean_fitness(i) = mean(fitnesses(idx));
            end
            plot(unique_pops, mean_fitness, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('种群大小', 'FontSize', 12);
            ylabel('平均适应度', 'FontSize', 12);
            title('种群大小影响', 'FontSize', 14);
            grid on;
            
            % 子图2: c_max影响
            subplot(1,3,2);
            unique_cmax = unique(c_maxs);
            mean_fitness_cmax = zeros(size(unique_cmax));
            for i = 1:length(unique_cmax)
                idx = c_maxs == unique_cmax(i);
                mean_fitness_cmax(i) = mean(fitnesses(idx));
            end
            plot(unique_cmax, mean_fitness_cmax, 's-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('c_{max}', 'FontSize', 12);
            ylabel('平均适应度', 'FontSize', 12);
            title('c_{max}影响', 'FontSize', 14);
            grid on;
            
            % 子图3: c_min影响
            subplot(1,3,3);
            unique_cmin = unique(c_mins);
            mean_fitness_cmin = zeros(size(unique_cmin));
            for i = 1:length(unique_cmin)
                idx = c_mins == unique_cmin(i);
                mean_fitness_cmin(i) = mean(fitnesses(idx));
            end
            semilogx(unique_cmin, mean_fitness_cmin, 'd-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('c_{min}（对数）', 'FontSize', 12);
            ylabel('平均适应度', 'FontSize', 12);
            title('c_{min}影响', 'FontSize', 14);
            grid on;
        end
        
        %% ============ 保存结果 ============
        function save_results(obj, filename)
            % 保存优化结果到文件
            
            if nargin < 2
                filename = sprintf('GOA_results_dim%d_%s.mat', ...
                                  obj.dim, datestr(now, 'yyyymmdd_HHMMSS'));
            end
            
            results.best_solution = obj.global_best;
            results.best_fitness = obj.global_best_fitness;
            results.convergence_curve = obj.convergence_curve;
            results.population = obj.population;
            results.execution_time = obj.execution_time;
            results.parameters.dim = obj.dim;
            results.parameters.pop_size = obj.pop_size;
            results.parameters.max_iter = obj.max_iter;
            results.parameters.c_min = obj.c_min;
            results.parameters.c_max = obj.c_max;
            
            save(filename, 'results');
            fprintf('结果已保存到: %s\n', filename);
        end
        
        %% ============ 显示统计摘要 ============
        function display_summary(obj)
            % 显示优化结果统计摘要
            
            fprintf('\n========== GOA优化结果摘要 ==========\n');
            fprintf('问题维度: %d\n', obj.dim);
            fprintf('种群大小: %d\n', obj.pop_size);
            fprintf('最大迭代次数: %d\n', obj.max_iter);
            fprintf('执行时间: %.2f 秒\n', obj.execution_time);
            fprintf('最优适应度值: %.6e\n', obj.global_best_fitness);
            fprintf('收敛迭代次数: %d\n', find(obj.convergence_curve <= ...
                                            1.01*obj.global_best_fitness, 1));
            
            % 显示最优解的前几个维度
            fprintf('最优解（前10维）: \n');
            display_dims = min(10, obj.dim);
            for d = 1:display_dims
                fprintf('  x%d = %.6f\n', d, obj.global_best(d));
            end
            if obj.dim > 10
                fprintf('  ... 还有 %d 个维度\n', obj.dim - 10);
            end
        end
    end
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

