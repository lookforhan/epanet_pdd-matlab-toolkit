% analysis for the chosen scenario
clear;clc;close all;
load('Scenario.mat');
input_net_name1 = 'GWSL_pump1.inp';
input_net_name2 = 'GWSL_4.inp';
input_rr_file_name = 'GWSL_4_RR_IX.txt';
MC = MC_simulation(input_rr_file_name,input_net_name2);
MC.MC_Nmax = 1;
MC.ChosenScenarioIndex = 1;
MC.Damage_info = DamageScenario;
MC.pre_damage_analysis
MC.export_inp('MC5_nopump.inp')
MC.delete

