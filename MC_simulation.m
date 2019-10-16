classdef MC_simulation < handle
    % a 'CLASS for Monte Carlo simulation'
    % In this script, when we use 'the CLASS', 'this CLASS' or other class 
    % without explanation , we all refer to the 'CLASS for Monte Carlo
    % simulation'.
    properties
        RR_file
        Net_file
    end
    properties % parameter
        Random_method = 'random';
        Random_value
        MC_Nmax = 50;
    end
    properties % output
        Node_supply
        Reservior_output
        Leak_flow
        Damage_info % damage information
    end
    properties % data used in process
        Net_pdd_file = 'PDDNet.inp';
        Net_basic_information
        RR_data
        PipeProbability
    end
    methods
        function obj = MC_simulation (inputArg1,inputArg2)
            % construct
            if isfile(inputArg1)
                obj.RR_file = inputArg1;
            else
                disp(['please check',inputArg1])
            end
            if isfile(inputArg2)
                obj.Net_file = inputArg2;
            else
                disp(['please check',inputArg2]);
            end
        end
        function delete(obj)
            % close file-built in analysis process
            % close(obj.Net_pdd_file); % close file created by the CLASS

            
            if isfile(obj.Net_pdd_file)
                delete(obj.Net_pdd_file); % delete file created by the CLASS
            end
            if libisloaded('epanet2.dll')
                unloadlibrary('epanet2.dll');
            end
        end
        function initial(obj)
            obj.RR_data = [];
            obj.Net_basic_information = [];
            obj.PipeProbability = [];
            obj.Random_value = [];
            obj.Net_pdd_file = 'PDDNet.inp';
            obj.Random_method = 'random';
            obj.MC_Nmax = 50;
        end
        function pre_analysis(obj)
            % input RR_file
            % input Net_file
            % prepare for analysis
            obj.input_RR;
            obj.pre_damage_analysis;
        end
        function generate_damage_info(obj)
            MC_NUM = obj.MC_Nmax; 
            break_probability = obj.PipeProbability.Break;
            leak_probability = obj.PipeProbability.Leak;
            damage_information = cell(MC_NUM,1);
            for i = 1:MC_NUM
                disp(['MC number:',num2str(i),'/',num2str(MC_NUM)])
                rand_value = obj.Random_value(i,:)';
                t_gdd = generate_damage_random(...
                    obj.RR_data.PipeID,...
                    obj.RR_data.Material,...
                    obj.RR_data.Length_km_,...
                    obj.RR_data.Diameter_mm_,...
                    obj.RR_data.RR,...
                    break_probability,...
                    leak_probability);
                [pipe_damage_data] = t_gdd.LeakAreaByType(rand_value);
                t_gdd.delete;
                damage_data = pipe_damage_data;
                mu = 0.62;C = 4427; pipe_damage_num_max = 100;pipe_id = obj.RR_data.PipeID;
                [~,damage_pipe_info] = ND_Execut_probabilistic4(pipe_id,damage_data,pipe_damage_num_max,C,mu);% from 'damageNet\'
                damage_information{i,1} = damage_pipe_info;
            end
            obj.Damage_info = damage_information;
        end
        function analysis(obj)
            MC_NUM = obj.MC_Nmax;
            Node_num = numel(obj.Net_basic_information.Node_id);
            Link_num = numel(obj.RR_data.PipeID);
            node_pressure_MC = zeros(Node_num,MC_NUM);
            node_actualDemand_MC = zeros(Node_num,MC_NUM);
            VariableName = cell(1,MC_NUM);
            node_leak_pressure_MC = zeros(Link_num*20,MC_NUM);
            node_leak_actualDemand_MC = zeros(Link_num*20,MC_NUM);
            Node_leak_pressure_id_cell = cell(Link_num*20,MC_NUM);
            Node_leak_demand_id_cell = cell(Link_num*20,MC_NUM);
            OriginalReservior_id = obj.Net_basic_information.OriginalReservior_id;
            Reservior_num = numel(OriginalReservior_id);
            Reservior_flow = zeros(Reservior_num,MC_NUM);
            
            Node_id = obj.Net_basic_information.Node_id;
            Node_R_id = obj.Net_basic_information.NodeReservoir_id;
            
            % damage information
            
            for i = 1:MC_NUM
                disp(['MC number:',num2str(i),'/',num2str(MC_NUM)])
                
                damage_pipe_info = obj.Damage_info{i};% read damage inforamtion 
                
                damage_pipe_id = damage_pipe_info.Pipe_ID;
                intervalLength = damage_pipe_info.Interval_Length;
                equalDiameter = damage_pipe_info.Equal_Damage_Diameter_m_*1000;% Unit:mm
                damageType = cell(numel(damage_pipe_info.Damage_Type),1);
                damageType(damage_pipe_info.Damage_Type==1) = {'L'};
                damageType(damage_pipe_info.Damage_Type==2) = {'B'};
                damageType(damage_pipe_info.Damage_Type==0) = {'N'};
%                 outdir = pwd;
%                 type = obj.Random_method;
                output_net_pdd_name = obj.Net_pdd_file;
%                 MC_out_inp = [outdir,'\damage',type,num2str(i),'.inp'];
                t  = EMT_add_damage(output_net_pdd_name);
                t.add_info(damage_pipe_id,intervalLength,damageType,equalDiameter);
                t.add2net;%add2net函数不能和closeNetwork函数同时使用
                Leak_data_table = struct2table(t.Leak_info);
                Node_leak_pressure_id = unique(table2cell(Leak_data_table(:,4:5)))';
                Node_leak_demand_id = unique(table2cell(Leak_data_table(:,2:3)))';
                Node_leak_pressure_id_cell(1:numel(Node_leak_pressure_id),i) = Node_leak_pressure_id';
                Node_leak_demand_id_cell(1:numel(Node_leak_demand_id),i) = Node_leak_demand_id';
                %     t.saveInpFile(MC_out_inp)
                t.Epanet.setOptionsMaxTrials(200);
                t.solveH
                Node_p_index = t.Epanet.getNodeIndex(Node_id);
                Node_d_index = t.Epanet.getNodeIndex(Node_R_id);
                Node_l_p_index = t.Epanet.getNodeIndex(Node_leak_pressure_id);
                Node_l_d_index = t.Epanet.getNodeIndex(Node_leak_demand_id);
                node_pressure_MC(:,i) = t.Epanet.getNodePressure(Node_p_index)';
                node_actualDemand_MC(:,i) = t.Epanet.getNodeActualDemand(Node_d_index)';
                node_leak_pressure_MC(1:numel(Node_l_p_index),i) = t.Epanet.getNodePressure(Node_l_p_index)';
                node_leak_pressure_MC(all(node_leak_pressure_MC==0,2),:)=[];
                node_leak_actualDemand_MC(1:numel(Node_l_d_index),i) = t.Epanet.getNodeActualDemand(Node_l_d_index)';
                node_leak_actualDemand_MC(all(node_leak_actualDemand_MC==0,2),:)=[];
                Reservior_index = t.Epanet.getNodeIndex(OriginalReservior_id);
                Reservior_flow(:,i) = t.Epanet.getNodeActualDemand(Reservior_index)';
                % t.preReport(MC_out_rpt);
                % t.closeNetwork;
                t.delete
                VariableName{i} = ['MC_',num2str(i)];
            end
            T_demand_MC = array2table(node_actualDemand_MC,'VariableNames',VariableName);
            T_pressure_MC = array2table(node_pressure_MC,'VariableNames',VariableName);
%             T_demand = [T_demand,T_demand_MC];
%             T_pressure = [T_pressure,T_pressure_MC];
            obj.Node_supply.Pressure = T_pressure_MC;
            obj.Node_supply.Demand = T_demand_MC;
            obj.Reservior_output = array2table(Reservior_flow,'VariableNames',VariableName);
            obj.Leak_flow.Demand = array2table(node_leak_actualDemand_MC,'VariableNames',VariableName);
            obj.Leak_flow.Pressure = array2table(node_leak_pressure_MC,'VariableNames',VariableName);
            
            
        end
        function post_analysis(obj)
            % data process
            % Normalized output
            disp('pressure (m) at each node')
            obj.Node_supply.Pressure
            disp('actural water supply (LPS) at each node')
            obj.Node_supply.Demand
            disp('actural water supply (LPS) at each ')
            obj.Reservior_output
            disp('pressure (m) at each artificial node')
            obj.Leak_flow.Pressure
            disp('actural water supply (LPS) at each artificial node')
            obj.Leak_flow.Demand
            disp('damage information')
            obj.Damage_info{1}
        end
    end
    methods %
        function pre_damage_analysis(obj)
            input_net_name = obj.Net_file;
            output_net_pdd_name = obj.Net_pdd_file;
            net = epanet_pdd(input_net_name);
            Original_Reservior_id = net.Epanet.NodeReservoirNameID;
            net.createAllNodePDD(output_net_pdd_name);
            Node_id = net.Nodes;
            Node_R_id = net.Reservoirs;
            Node_index = net.Epanet.getNodeIndex(Node_id);
            Node_R_index = net.Epanet.getNodeIndex(Node_R_id);
            Pipe_id = net.LinksInfo.BinLinkPipeNameID;
            net.Epanet.solveCompleteHydraulics;
            node_pressure = net.Epanet.getNodePressure(Node_index);
            node_actualDemand = net.Epanet.getNodeActualDemand(Node_R_index);
            net.Epanet.closeNetwork;
            net.delete;
            %             node_pressure_mean = mean(node_pressure);
            %             node_actualDemand_sum = sum(node_actualDemand);
            obj.Net_basic_information.Node_id = Node_id;
            obj.Net_basic_information.NodeReservoir_id = Node_R_id;
            obj.Net_basic_information.Pipe_id = Pipe_id;
            obj.Net_basic_information.Node_pressure = node_pressure;
            obj.Net_basic_information.Node_actualDemand = node_actualDemand;
            obj.Net_basic_information.OriginalReservior_id = Original_Reservior_id;
        end
        function input_RR(obj)
            RRdata = readtable(obj.RR_file);
            if isnumeric(RRdata.PipeID)
                cell_char_PipeID = cell(numel(RRdata.PipeID),1);
                for i = 1:numel(RRdata.PipeID)
                    cell_char_PipeID{i} = num2str(RRdata.PipeID(i));
                end
                RRdata.PipeID = cell_char_PipeID;
            end
            obj.RR_data = RRdata;
        end
        function random_value(obj)
            type = obj.Random_method;
            MC_NUM = obj.MC_Nmax;
            Link_num = numel(obj.RR_data.PipeID);
            switch sum(abs(type))
                case 641
                    rnd_num = unifrnd(0,1,[MC_NUM,Link_num]);
                case 543
                    sobol_seed = sobolset(Link_num);
                    sobol_seed_random = scramble(sobol_seed,'MatousekAffineOwen');
                    rnd_num = sobol_seed_random.net(MC_NUM);
            end
            obj.Random_value = rnd_num;
        end
        function generate_damage_probability(obj)
            RRdata = obj.RR_data;
            break_probability = 1-exp(-RRdata.RR.*RRdata.Length_km_);% 计算破坏概率
            leak_probability = 5*break_probability;
            damage_probability = break_probability+leak_probability;
            obj.PipeProbability.Break = break_probability;
            obj.PipeProbability.Leak = leak_probability;
            obj.PipeProbability.Damage = damage_probability;
        end
    end
end