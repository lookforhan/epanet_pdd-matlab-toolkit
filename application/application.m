% application
% the MC_simulation.m is used to simulate the network model with pump and
% with pump.
input_net_name1 = 'GWSL_pump1.inp';
input_net_name2 = 'GWSL_4.inp';
input_rr_file_name = 'GWSL_4_RR_IX.txt';
MC = MC_simulation(input_rr_file_name,input_net_name1);
MC.MC_Nmax = 1000;
MC.pre_analysis
MC.random_value
MC.generate_damage_probability
MC.generate_damage_info
DamageScenario = MC.Damage_info;
save('Scenario.mat','DamageScenario');
MC.analysis
MC.post_analysis
WithPump = saveobj(MC);
save('resultWithPump.mat','WithPump')
MC.delete

% without pump

MC = MC_simulation(input_rr_file_name,input_net_name2);
MC.MC_Nmax = 1000;
MC.pre_analysis
MC.Damage_info = DamageScenario;
MC.analysis
MC.post_analysis
WithoutPump = saveobj(MC);
save('resultWithoutPump.mat','WithoutPump');
MC.delete