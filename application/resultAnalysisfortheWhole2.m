% result analysis
clear;clc;close all;
load('resultWithoutPump_0.6_MC500.mat');
load('resultWithPump_0.6_MC500.mat');

supplyFlow_withPump = WithPump.Node_supply.Demand.Variables;
sum_supplyFlow_withPump = sum(supplyFlow_withPump);
mean_sum_supplyFlow_withPump = mean(sum_supplyFlow_withPump);

leakFlow_withPump = WithPump.Leak_flow.Demand.Variables;
sum_leakFlow_withPump = sum(leakFlow_withPump);
mean_sum_leakFlow_withPump = mean(sum_leakFlow_withPump);

supplyFlow_withoutPump = WithoutPump.Node_supply.Demand.Variables;
sum_supplyFlow_withoutPump = sum(supplyFlow_withoutPump);
mean_sum_supplyFlow_withoutPump = mean(sum_supplyFlow_withoutPump);

leakFlow_withoutPump = WithoutPump.Leak_flow.Demand.Variables;
sum_leakFlow_withoutPump = sum(leakFlow_withoutPump);
mean_sum_leakFlow_withoutPump = mean(sum_leakFlow_withoutPump);
y = [mean_sum_supplyFlow_withPump,mean_sum_leakFlow_withPump;...
    mean_sum_supplyFlow_withoutPump,mean_sum_leakFlow_withoutPump];