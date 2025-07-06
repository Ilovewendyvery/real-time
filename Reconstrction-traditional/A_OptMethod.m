classdef (Abstract) A_OptMethod
    properties (Abstract) 
        iter_max;
        beta;
    end
    methods (Abstract)   
        Solve(obj);
        Solve_convergence(obj);
    end
end