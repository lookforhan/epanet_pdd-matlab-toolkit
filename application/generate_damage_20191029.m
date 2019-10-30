% ���ݹܵ����Ⱥ�RRȷ���ƻ�������Ȼ����ݶϿ�����ȷ���Ͽ���й©����
% ��©����ѡ�� AD
% ��©������㹫ʽΪ��k4 = 0.3;
%                     t = 10/1000;
%                     Area=t*k4*Diameter*pi;
% �������һ��DamageScenario {}
k4 = 0.3;
t = 10/1000;
RRdata = readtable('GWSL_4_RR_IX.txt');
DamageNumber = ceil(sum(RRdata.Length_km_.*RRdata.RR));
Diameter = RRdata.Diameter_mm_;
BreakRate = 0.6;%0.2;0.4;0.6

BreakNum = ceil(DamageNumber*BreakRate);
LeakNum = DamageNumber-BreakNum;

pipe_damage_data=cell(1,6);% pipe_damage_data,Ԫ������,���6��������ͬ������������������ƻ�������
pipe_damage_data{1,1}=(1:DamageNumber)'; %�ƻ���ı��

mid_pipe_id = RRdata.PipeID;
loc = unique(randperm(numel(mid_pipe_id),DamageNumber));
damage_pipe_id = mid_pipe_id(loc);
damageDiameter = Diameter(damage_pipe_id);
mid_cell = num2cell(damage_pipe_id);
pipe_damage_data{1,2} = cellfun(@(x)num2str(x),mid_cell,'UniformOutput',false);%�ƻ������ڹ��ߵı��
% pipe_damage_data{1,2}=cell(DamageNumber,1); %�ƻ������ڹ��ߵı��
pipe_damage_data{1,3}=ones(DamageNumber,1); %�ù��ߵ��ƻ�����
pipe_damage_data{1,4}=ones(DamageNumber,1)*0.5; %ǰ���ƻ���ĳ��ȱ���
% pipe_damage_data{1,5}=ones(DamageNumber,1); %�ƻ����ͣ�1��©��2�Ͽ�
mid_type = [ones(LeakNum,1);ones(BreakNum,1)*2];
pipe_damage_data{1,5} = mid_type(randperm(DamageNumber));
pipe_damage_data{1,6}=zeros(DamageNumber,1); %�ƻ��㴦��©�����m^2
pipe_damage_data{1,7}=cell(DamageNumber,1); %й©�ƻ�����
for i = 1:DamageNumber
    switch pipe_damage_data{1,5}(i)
        case 1
            pipe_damage_data{1,6}(i) = damageDiameter(i)*pi*t*k4*(1E-6);
            pipe_damage_data{1,7} = 'AD';
        case 2
            pipe_damage_data{1,6}(i) = 0.25*pi*damageDiameter(i)^2;
            pipe_damage_data{1,7} = 'B';
    end
end
damage_data = pipe_damage_data;
mu = 0.62;C = 4427; pipe_damage_num_max = 100;pipe_id = cellfun(@(x)num2str(x),num2cell(RRdata.PipeID),'UniformOutput',false);
[~,damage_pipe_info3] = ND_Execut_probabilistic4(pipe_id,damage_data,pipe_damage_num_max,C,mu);% from 'damageNet\'
%{
DamageScenario{1,1} = damage_pipe_info1
DamageScenario{2,1} = damage_pipe_info2
DamageScenario{3,1} = damage_pipe_info3
save('Scenario_0.6_.mat','DamageScenario')
%}