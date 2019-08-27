% main.m
% 1. 随机生成管道破坏；
% 2. 采用新的PDD方法进行水力模拟
% 3. 统计所需要及数据
% % 修改记录
% 2019-8-25 ： pipe_damage_data改由 generate_damage_random class 生成
% start_toolkit()
clear;close all;tic;
% 1 为为了进行PDD，对输入管网进行改造。新的PDD计算如Paez et al. 2018所描述。
input_net_name = 'GWSL_4.INP';
input_rr_file_name = 'GWSL_4_RR.txt';
output_net_pdd_name = [input_net_name(1:end-4),'_pdd','.inp'];
% output_net_pdd_name = 'net03.inp';
%{
% 随机分析之前运行，运行后保存关键变量。
net = epanet_pdd(input_net_name);
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

node_pressure_mean = mean(node_pressure);
node_actualDemand_sum = sum(node_actualDemand);
% 2 生成破坏管网模型
% 2,1 读入RR信息
RRdata = readtable(input_rr_file_name);
if isnumeric(RRdata.PipeID)
    cell_char_PipeID = cell(numel(RRdata.PipeID),1);
    for i = 1:numel(RRdata.PipeID)
        cell_char_PipeID{i} = num2str(RRdata.PipeID(i));
    end
    RRdata.PipeID = cell_char_PipeID;
end
id_flag = strcmp(Pipe_id',RRdata.PipeID);
if ~all(id_flag)
    disp('There are difference between the Pipe_id from inpfile AND the RRdata.PipeID from RRfile!');
    keyboard
    return
end
save('pre_data_GWSL_4.mat','RRdata','node_pressure','node_actualDemand','Node_R_id','Node_id');
%}
load('pre_data_GWSL_4.mat');
node_pressure_mean = mean(node_pressure);
node_actualDemand_sum = sum(node_actualDemand);
damage_probability = 1-exp(-RRdata.RR.*RRdata.Length_km_);% 计算破坏概率
link_num = numel(RRdata.PipeID);
pipe_id= RRdata.PipeID;

% outdir = pwd;
% outdir = 'C:\Users\dell\Desktop\random\抽样记录';
outdir = [pwd,'\random',];
MC_NUM = 1000;
Node_num = numel(Node_id);
sobol_seed = sobolset(link_num);
sobol_seed_random = scramble(sobol_seed,'MatousekAffineOwen');
rnd_num = sobol_seed_random.net(MC_NUM);
type = 'sobol';
% type = 'random';
% rnd_num = unifrnd(0,1,[MC_NUM,link_num]);
node_pressure_MC = zeros(Node_num,MC_NUM);
node_actualDemand_MC = zeros(Node_num,MC_NUM);
VariableName = cell(1,MC_NUM);
T_pressure = table(node_pressure','VariableNames',{'basePressure'});
T_demand = table(node_actualDemand','VariableNames',{'baseDemand'});

% waitmsg = waitbar(i/MC_NUM,['Please wait!','the ',num2str(i),' of ',num2str(MC_NUM),...
%         'estimated time remaining indicating ',num2str((MC_NUM-i)*3.43),' minutes']);
for i = 1:MC_NUM
    
        rand_P = rnd_num(i,:)';
%     n_start = (i-1)*link_num+4;
%     rand_P = sobol_P(n_start:n_start+link_num-1);
%     pipe_damage_data = generate_damage_data(RRdata,rand_P, damage_probability); % 修改
    t_gdd = generate_damage_random(RRdata.PipeID,RRdata.Material,RRdata.Length_km_,RRdata.Diameter_mm_,RRdata.RR,damage_probability);
%     [pipe_damage_data] = t_gdd.weightedMeanLeakArea(rand_P);
    [pipe_damage_data] = t_gdd.LeakAreaByType(rand_P);
    t_gdd.delete;
    % 
    % 2.2 随机生成破坏管道信息
    damage_data= pipe_damage_data;
    mu = 0.62;C = 4427;pipe_damage_num_max=100;% 参数
    [t4_2,damage_pipe_info] = ND_Execut_probabilistic4(pipe_id,damage_data,pipe_damage_num_max,C,mu);% from 'damageNet\'
    damage_pipe_id = damage_pipe_info.Pipe_ID;
    intervalLength = damage_pipe_info.Interval_Length;
    equalDiameter = damage_pipe_info.Equal_Damage_Diameter_m_*1000;% Unit:mm
    damageType = cell(numel(damage_pipe_info.Damage_Type),1);
    damageType(damage_pipe_info.Damage_Type==1) = {'L'};
    damageType(damage_pipe_info.Damage_Type==2) = {'B'};
    damageType(damage_pipe_info.Damage_Type==0) = {'N'};
    MC_out_inp = [outdir,'\damage',type,num2str(i),'.inp'];
    % MC_out_rpt = [outdir,'\report',type,num2str(i),'.txt'];
    t  = EMT_add_damage(output_net_pdd_name);
    % t.add_info({'3';'4'},[0.2,0.4,0.4;0.5,0.5,0],{'L','B';'B','N'},[100,0;0,0])
    t.add_info(damage_pipe_id,intervalLength,damageType,equalDiameter);
    t.add2net;%add2net函数不能和closeNetwork函数同时使用
    t.saveInpFile(MC_out_inp)
    t.Epanet.setOptionsMaxTrials(100);
    t.solveH
    Node_p_index = t.Epanet.getNodeIndex(Node_id);
    Node_d_index = t.Epanet.getNodeIndex(Node_R_id);
    node_pressure_MC(:,i) = t.Epanet.getNodePressure(Node_p_index)';
    node_actualDemand_MC(:,i) = t.Epanet.getNodeActualDemand(Node_d_index)';
    % t.preReport(MC_out_rpt);
    % t.closeNetwork;
    t.delete
    VariableName{i} = ['MC_',num2str(i)];
end
% 时间已过 343.055553 秒。平均3.43s一次模拟，包括：生成破坏，水力模拟，加载动态连接库，卸载动态链接库/
% 时间已过 331.519547 秒。平均3.32s一次模拟，不包括水力模拟。
% waitmsg.delete
toc;
% sum(T_demand)
T_demand_MC = array2table(node_actualDemand_MC,'VariableNames',VariableName);
T_pressure_MC = array2table(node_pressure_MC,'VariableNames',VariableName);
T_demand = [T_demand,T_demand_MC];
T_pressure = [T_pressure,T_pressure_MC];
% writetable(T_demand,'demand.txt');
% writetable(T_pressure,'pressure.txt');
% post-analysis
SSI_Q = sum(node_actualDemand_MC)./node_actualDemand_sum;
SSI_H = mean(node_pressure_MC)./node_pressure_mean;
save([type,'-leakType-','post_data_GWSL_4.mat'],'SSI_Q','SSI_H','T_demand','T_pressure','MC_NUM','type','outdir')
% plot(SSI_Q);
% figure
% plot(SSI_H);
% toc
% mean_num = 1:MC_NUM;
Q_mean = cumsum(SSI_Q)./(1:MC_NUM);
H_mean = cumsum(SSI_H)./(1:MC_NUM);
Q_sd = sqrt(cumsum((SSI_Q-Q_mean).^2)./(1:MC_NUM));
H_sd = sqrt(cumsum((SSI_H-H_mean).^2)./(1:MC_NUM));
Q_vc = Q_sd./Q_mean;
H_vc = H_sd./H_mean;
figure
f1 = plot(Q_mean);
figure
f2 = plot(H_mean);
% figure
