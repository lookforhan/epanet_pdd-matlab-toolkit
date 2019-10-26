% analysis of the results
% start_toolkit() % this commond is necessary for load data
clear;clc;close all;
load('resultWithoutPump.mat');
load('resultWithPump.mat');
load('Scenario.mat');

basicReserviorSupply = WithPump.Net_basic_information.OriginalReservoir_supply;
basicReserviorSupplySum = sum(basicReserviorSupply);
basicNodeFlow = WithPump.Net_basic_information.Node_actualDemand;
basicNodeFlowSum = sum(basicNodeFlow);


chosenDamageScenarioIndex = 5;

damageScenario = DamageScenario{chosenDamageScenarioIndex};

chosenScenario_Reservior_outflow_withPump = WithPump.Reservior_output(:,chosenDamageScenarioIndex);
theWholeSupply_withPump  = sum(chosenScenario_Reservior_outflow_withPump.Variables);
chosenScenario_Leak_flow_withPump = WithPump.Leak_flow.Demand(:,chosenDamageScenarioIndex);
theWholeLeak_withPump  = sum(chosenScenario_Leak_flow_withPump.Variables);
chosenScenario_Node_flow_withPump = WithPump.Node_supply.Demand(:,chosenDamageScenarioIndex);
theWholeNodeSupply_withPump  = sum(chosenScenario_Node_flow_withPump.Variables);
test = theWholeSupply_withPump +theWholeLeak_withPump +theWholeNodeSupply_withPump ;
%
chosenScenario_Reservior_outflow_withOutPump = WithoutPump.Reservior_output(:,chosenDamageScenarioIndex);
theWholeSupply_withOutPump  = sum(chosenScenario_Reservior_outflow_withOutPump.Variables);
chosenScenario_Leak_flow_withOutPump = WithoutPump.Leak_flow.Demand(:,chosenDamageScenarioIndex);
theWholeLeak_withOutPump  = sum(chosenScenario_Leak_flow_withOutPump.Variables);
chosenScenario_Node_flow_withOutPump = WithoutPump.Node_supply.Demand(:,chosenDamageScenarioIndex);
theWholeNodeSupply_withOutPump  = sum(chosenScenario_Node_flow_withOutPump.Variables);
test_Out = theWholeSupply_withOutPump +theWholeLeak_withOutPump +theWholeNodeSupply_withOutPump ;
y = [basicNodeFlowSum,0;...
    theWholeNodeSupply_withPump,theWholeLeak_withPump;...
    theWholeNodeSupply_withOutPump,theWholeLeak_withOutPump];

%»æÖÆÖù×´Í¼

c = categorical({'basic','withPump','withoutPump'});
barfig = bar(c,y,'stacked');
barfig(1).DisplayName = 'SupplyToUsers';
barfig(2).DisplayName = 'Leakage';
ylim([5500,7000])
legend('show');
%}

% Ñ¹Á¦
theChosenScenario_node_pressure_withPump = WithPump.Node_supply.Pressure(:,chosenDamageScenarioIndex);
theChosenScenario_node_mean_pressure_withPump = mean(theChosenScenario_node_pressure_withPump.Variables);
theChosenScenario_leak_pressure_withPump = WithPump.Leak_flow.Pressure(:,chosenDamageScenarioIndex);
theChosenScenario_leak_mean_pressure_withPump = mean(theChosenScenario_leak_pressure_withPump.Variables);

theChosenScenario_node_pressure_withOutPump = WithoutPump.Node_supply.Pressure(:,chosenDamageScenarioIndex);
theChosenScenario_node_mean_pressure_withOutPump = mean(theChosenScenario_node_pressure_withOutPump.Variables);
theChosenScenario_leak_pressure_withOutPump = WithoutPump.Leak_flow.Pressure(:,chosenDamageScenarioIndex);
theChosenScenario_leak_mean_pressure_withOutPump = mean(theChosenScenario_leak_pressure_withOutPump.Variables);
