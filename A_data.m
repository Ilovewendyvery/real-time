classdef (Abstract) A_data
    properties (Abstract)
        Ne;% number of total EV
        Nr;% number of total residents
        T; % The number of portions that are divided in a day

        BPVL;% A class about Battery and PV and Load
        minREP;% A class that minimizes the objective function of ERP 
        minEV;% A class that minimizes the objective function of EV
        minResident;% A class that minimizes the objective function of Resident 

        % Parameters about EV
        beta_ev;
        omega_ev;
        Pmax_ev; 
        Capacity_EV;
        

        % Parameters about Resident
        alpha_re;
        omega_re;

        % Parameters about REP
        a_rep;
        b_rep;
        c_rep;

        % Parameters about battery
        Capacity_bat;% kw*h        
        
        % Parameters about PV
        GC;  %A matrix of power regarding the needs of residents
        GG;  %A matrix regarding the power of PV generation        
        %£¨Columns correspond to times, rows correspond to users£©
        
        % Parameters about feeder
        number_of_feeder; % Total number of feeders      
        U_feeder;%A matrix containing feeder connectivity and user distribution information
        B_feeder;%A vector of feeder capacity

    end
    methods (Abstract)  
    end
end