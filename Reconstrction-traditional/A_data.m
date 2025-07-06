classdef (Abstract) A_data
    properties (Abstract)
        Ne;Nr;T;

        BPVL;
        minREP;
        minEV;
        minResident;

        % for EV
        beta;omega_e;thresholds; %kw

        % for Resident
        alpha;omega_r;

        % for REP
        a;b;c;

        % for battery
        Bat_cap;% kw*h

        numer_of_feed;

        GC; %Columns correspond to times, rows correspond to users 
        GG;
  
        A;
        B;

    end
    methods (Abstract)  
    end
end