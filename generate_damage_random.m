classdef generate_damage_random < handle
    %generate_damage_random �˴���ʾ�йش����ժҪ
    %   ���ݹܵ�ƽ���ƻ���RR����/km�����ܵ����ȺͲ���
    %   ������ɹܵ�״̬����ã��Ͽ���й©����ͬй©�����
    %   ����ÿ���ܵ�ֻ��һ���ƻ��㡣
    
    properties
        PipeID
        PipeMaterial
        PipeLength
        PipeDiameter
        PipeRR
        Pipe_damage_probability
    end
    properties (Dependent)
        Leak_type_cdf_table
%         Pipe_damage_probability
    end
    properties
        Leak_area_probability = [0.3,0.5,0.1,0.1,0.0;...
            0.8,0.0,0.1,0.1,0.0;...
            0.6,0.0,0.3,0.1,0.0;...
            0.0,0.0,0.0,0.0,1.0;...
            1.0,0.0,0.0,0.0,0.0]
    end
    methods
        function obj = generate_damage_random(inputArg1,inputArg2,...
                inputArg3,inputArg4,inputArg5,inputArg6)
            %generate_damage_random ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.PipeID = inputArg1;
            obj.PipeMaterial = inputArg2;
            obj.PipeLength = inputArg3;
            obj.PipeDiameter = inputArg4;
            obj.PipeRR = inputArg5;
            obj.Pipe_damage_probability = inputArg6; 
        end
    end
    methods
        function Leak_type_cdf_table = get.Leak_type_cdf_table(obj)
            Leak_area_cdf = cumsum(obj.Leak_area_probability,2);
            rowNames = {'CastIron';'DuctileIron';'RivetedSteel';'WeldedSteel';'JointedConcrete'};
            varNames = {'AnnluarDisengagement','RoundCrack','LongitudinalCrack','LocalLoss','LocalTear'};
            Leak_type_cdf_table = array2table(Leak_area_cdf,'VariableNames',varNames,'RowNames',rowNames);
        end
    end
    methods
        function pipe_damage_data = weightedMeanLeakArea(obj,rand_P)
%             Leak_type_cdf = obj.Leak_area_cdf;

            link_num = numel(obj.PipeID);
            Pf = obj.Pipe_damage_probability;
            j = 1;k =0;
            damage_type1 = zeros(link_num,1);
            damage_type2 = zeros(link_num,1);
            pipe_damage_data=cell(1,6);% pipe_damage_data,Ԫ������,���6��������ͬ������������������ƻ�������
            pipe_damage_data{1,1}=zeros(link_num,1); %�ƻ���ı��
            pipe_damage_data{1,2}=cell(link_num,1); %�ƻ������ڹ��ߵı��
            pipe_damage_data{1,3}=zeros(link_num,1); %�ù��ߵ��ƻ�����
            pipe_damage_data{1,4}=zeros(link_num,1); %ǰ���ƻ���ĳ��ȱ���
            pipe_damage_data{1,5}=zeros(link_num,1); %�ƻ����ͣ�1��©��2�Ͽ�
            pipe_damage_data{1,6}=zeros(link_num,1); %�ƻ��㴦��©�����m^2
            link_D = zeros(link_num,1);% �ܵ�ֱ��mm
            for i=1:link_num
                judge_interval=[0 0.2*Pf(i) Pf(i) 1];
                mid_a=rand_P(i,1)>judge_interval;
                mid_b=sum(mid_a);
                switch mid_b
                    case 1 %�Ͽ�
                        damage_type1(j,i)=1;
                        k=k+1;
                        pipe_damage_data{1,1}(k,1)=k;
                        pipe_damage_data{1,2}{k,1}=obj.PipeID{i};
                        pipe_damage_data{1,3}(k,1)=1;
                        pipe_damage_data{1,4}(k,1)=0.5;
                        pipe_damage_data{1,5}(k,1)=2;
                        pipe_damage_data{1,6}(k,1)=0.25*pi*(obj.PipeDiameter(i)/1000)^2;
                    case 2 %��©
                        damage_type2(j,i)=1;
                        k=k+1;
                        pipe_damage_data{1,1}(k,1)=k;
                        pipe_damage_data{1,2}{k,1}=obj.PipeID{i};
                        pipe_damage_data{1,3}(k,1)=1;
                        pipe_damage_data{1,4}(k,1)=0.5;
                        pipe_damage_data{1,5}(k,1)=1;
                        pipe_type = sum(abs(obj.PipeMaterial{i}));
                        link_D(i) = obj.PipeDiameter(i);
                        switch pipe_type %���ڲ�ͬ�Ĺܲķֱ��5����©��ʽ(�����ɶ�,�����ѷ�,�����ѷ�,�ܱ�����,�ܱ�˺��)����©���������Ӧ�ķ����������Ȩƽ����Ϊ�ù��ߵ���©���
                            case 140 % Cast Iron; sum(abs('CI'))
                                pipe_damage_data{1,6}(k,1)=(0.3*0.3*pi*(10/1000)*(link_D(i)/1000))+...
                                    (0.5*0.5*0.5*pi*(link_D(i)/1000)^2)+(0.1*0.1*30/1000*(link_D(i)/1000))+(0.1*0.05^2*pi*(link_D(i)/1000)^2);
                            case 141 % Ductile Iron; sum(abs('DI'))
                                pipe_damage_data{1,6}(k,1)=(0.8*0.3*pi*10/1000*(link_D(i)/1000))+...
                                    (0.1*0.1*30/1000*(link_D(i)/1000))+(0.1*0.05^2*pi*(link_D(i)/1000)^2);
                            case 165 % Revieted Steel; sum(abs('RS'))
                                pipe_damage_data{1,6}(k,1)=(0.6*0.3*pi*10/1000*(link_D(i)/1000))+...
                                    (0.3*0.1*30/1000*(link_D(i)/1000))+(0.1*0.05^2*pi*(link_D(i)/1000)^2);
                            case 243 % Welded Steel; sum(abs('STL'))
                                pipe_damage_data{1,6}(k,1)=1.0*0.3*pi*12/1000*(link_D(i)/1000);
                            case 224 % Jointed Concrete; sum(abs('CON'))
                                pipe_damage_data{1,6}(k,1)=1.0*0.3*pi*10/1000*(link_D(i)/1000);
                        end
                end
            end
            damage_num=sum(pipe_damage_data{1,1}>0);
            pipe_damage_data{1,1}=pipe_damage_data{1,1}(1:damage_num,1);
            pipe_damage_data{1,2}=pipe_damage_data{1,2}(1:damage_num,1);
            pipe_damage_data{1,3}=pipe_damage_data{1,3}(1:damage_num,1);
            pipe_damage_data{1,4}=pipe_damage_data{1,4}(1:damage_num,1);
            pipe_damage_data{1,5}=pipe_damage_data{1,5}(1:damage_num,1);
            pipe_damage_data{1,6}=pipe_damage_data{1,6}(1:damage_num,1);
            
        end
    end
end
