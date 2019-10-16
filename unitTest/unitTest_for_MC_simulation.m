% test CLASS MC_simulation.m
input_net_name = 'GWSL_pump1.inp';
input_rr_file_name = 'GWSL_4_RR_IX.txt';
% test for construct (pass)
MC = MC_simulation(input_rr_file_name,input_net_name);
% test for input RR file(pass)
MC.input_RR;
MC.RR_data
% test for previous hydraulic analysis of undamaged network (pass)
MC.Net_pdd_file = 'PDDNet.inp';
MC.pre_damage_analysis;
MC.Net_basic_information
% test for delete (PASS)
MC.delete
% test for preparation analysis (pass)
clc
MC = MC_simulation(input_rr_file_name,input_net_name);
MC.pre_analysis
MC.RR_data
MC.Net_basic_information
MC.delete
% test for random
MC = MC_simulation(input_rr_file_name,input_net_name);
MC.pre_analysis
MC.random_value
MC.Random_value
MC.delete
% test for generate damage probability
MC = MC_simulation(input_rr_file_name,input_net_name);
MC.input_RR;
MC.generate_damage_probability
MC.PipeProbability
MC.delete
% test for analysis (pass)
MC = MC_simulation(input_rr_file_name,input_net_name);
MC.pre_analysis
MC.random_value
MC.generate_damage_probability
MC.generate_damage_info
MC.analysis
MC.delete
% test for post analysis (pass)
MC = MC_simulation(input_rr_file_name,input_net_name);
MC.pre_analysis
MC.random_value
MC.generate_damage_probability
MC.generate_damage_info
MC.analysis
MC.post_analysis
MC.delete