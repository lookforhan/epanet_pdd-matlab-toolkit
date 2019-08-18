% main.m
% 1. ������ɹܵ��ƻ���
% 2. �����µ�PDD��������ˮ��ģ��
% 3. ͳ������Ҫ������

clear;close all;tic;
% 1 ΪΪ�˽���PDD��������������и��졣�µ�PDD������Paez et al. 2018��������
input_net_name = 'GWSL_4.INP';
input_rr_file_name = 'GWSL_4_RR.txt';
output_net_pdd_name = [input_net_name(1:end-3),'pdd','.inp'];
net = epanet_pdd(input_net_name);
net.createAllNodePDD(output_net_pdd_name);
net.delete;

% 2 �����ƻ�����ģ��
% 2,1 ����RR��Ϣ
RRdata = readtable(input_rr_file_name);
if isnumeric(RRdata.PipeID)
    cell_char_PipeID = cell(numel(RRdata.PipeID),1);
    for i = 1:numel(RRdata.PipeID)
        cell_char_PipeID{i} = num2str(RRdata.PipeID(i));
    end
    RRdata.PipeID = cell_char_PipeID;
end
damage_probability = 1-exp(-RRdata.RR.*RRdata.Length_km_);% �����ƻ�����
link_num = numel(RRdata.PipeID);
rand_P = unifrnd(0,1,[1,link_num]);
 pipe_damage_data = generate_damage_data(RRdata,rand_P, damage_probability);
% 2.2 ��������ƻ��ܵ���Ϣ
pipe_id= RRdata.PipeID;damage_data= pipe_damage_data;
[t4_2,damage_pipe_info] = ND_Execut_deterministic1(pipe_id,damage_data);% from 'damageNet\'
% if t4_2
%     keyboard
% end
% [t3,pipe_relative,node_relative_NewNode] = damageNetInp2_GIRAFFE2(net_data,damage_pipe_info,EPA_format,damage_net);% from 'damageNet\'
% if t3
%     keyboard
% else
% end
% pdd_net = epanet_add_damage(output_net_pdd_name);