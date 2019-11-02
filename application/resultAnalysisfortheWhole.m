% analysis of the whole scenarios
% analysis of the results
% start_toolkit() % this commond is necessary for load data
clear;clc;close all;
load('resultWithoutPump.mat');
load('resultWithPump.mat');
% load('Scenario.mat');

% prepare
NodeBasicDemand = WithPump.Net_basic_information.Node_actualDemand(1:49)';
NetBasicDemand = sum(NodeBasicDemand)';

NodeBasicDemand_mat = NodeBasicDemand*ones(1,1000);
NetBasicDemand_mat = NetBasicDemand*ones(1,1000);
% calculate the SI
NodeDemand_withPump_53 = WithPump.Node_supply.Demand.Variables;
NodeDemand_withPump = NodeDemand_withPump_53(1:49,:);

NodeSI_withPump = NodeDemand_withPump./NodeBasicDemand_mat;

NetSSI_withPump = sum(NodeDemand_withPump)./NetBasicDemand_mat;

mean_value_curve_withPump = cumsum(NetSSI_withPump)./(1:1000);
node_mean_value_curve_wtihPump = cumsum(NodeSI_withPump,2)./(ones(49,1)*(1:1000));
% plot(mean_value_curve_withPump)

NodeDemand_withoutPump = WithoutPump.Node_supply.Demand.Variables;

NodeSI_withoutPump = NodeDemand_withoutPump./NodeBasicDemand_mat;
NetSSI_withoutPump = sum(NodeDemand_withoutPump)./NetBasicDemand_mat;

mean_value_curve_withoutPump = cumsum(NetSSI_withoutPump)./(1:1000);
node_mean_value_curve_wtihoutPump = cumsum(NodeSI_withoutPump,2)./(ones(49,1)*(1:1000));
% plot(mean_value_curve_withoutPump)
% ylim([0.9,1])
% 节点分类
Node_SI_mean_withPump = mean(NodeSI_withPump,2);
Node_SI_mean_withoutPump = mean(NodeSI_withoutPump,2);
figure(1)
ph_withPump = histogram(Node_SI_mean_withPump);
ph_withPump.BinLimits = [0,1.01];
ph_withPump.NumBins = 5;
ph_withPump.Values
figure(2)
ph_withoutPump = histogram(Node_SI_mean_withoutPump);
ph_withoutPump.BinLimits = [0,1.01];
ph_withoutPump.NumBins = 5;
ph_withoutPump.Values
% 漏水量分析
leak_flow_withPump = sum(WithPump.Leak_flow.Demand.Variables);
leak_flow_mean_withPump = mean(leak_flow_withPump);
leak_rate_withPump = leak_flow_mean_withPump/NetBasicDemand;

leak_flow_withoutPump = sum(WithoutPump.Leak_flow.Demand.Variables);
leak_flow_mean_withoutPump = mean(leak_flow_withoutPump);
leak_rate_withoutPump = leak_flow_mean_withoutPump/NetBasicDemand;