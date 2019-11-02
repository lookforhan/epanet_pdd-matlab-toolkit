% application2.m
load('Scenario_0.2_.mat')
input_net_name1 = 'GWSL_pump1.inp';
input_net_name2 = 'GWSL_4.inp';
input_rr_file_name = 'GWSL_4_RR_IX.txt';
MC = MC_simulation(input_rr_file_name,input_net_name1);
MC.MC_Nmax = 3;
MC.pre_analysis
MC.Damage_info = DamageScenario;
MC.analysis
MC.post_analysis
WithPump = saveobj(MC);
save('resultWithPump.mat','WithPump');
MC.delete
MC_outpump = MC_simulation(input_rr_file_name,input_net_name2);
MC_outpump.MC_Nmax = 3;
MC_outpump.pre_analysis
MC_outpump.Damage_info = DamageScenario;
MC_outpump.analysis
MC_outpump.post_analysis
WithoutPump = saveobj(MC_outpump);
save('resultWithoutPump.mat','WithoutPump');
MC_outpump.delete