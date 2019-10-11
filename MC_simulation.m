classdef MC_simulation < handle
    properties
        RR_file
        Net_file
    end
    properties % parameter
        Random_method = 'random';
        MC_Nmax = 500;
    end
    properties % output
        Node_supply
        Reservior_output
        Leak_flow
    end
    methods % construct
        function obj = MC_simulation (inputArg1,inputArg2)
            obj.RR_file = inputArg1;
            obj.Net_file = inputArg2;
        end
    end
    methods %
        function Analysis(obj)
            Nmax = obj.MC_Nmax;
            for i = 1:Nmax
            end
        end
    end
end