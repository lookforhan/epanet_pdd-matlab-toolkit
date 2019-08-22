function pipe_damage_data = generate_damage_data(RRdata,rand_P, Pf)
link_num = numel(RRdata.PipeID);
j = 1;k =0;
damage_type1 = zeros(link_num,1);
damage_type2 = zeros(link_num,1);
pipe_damage_data=cell(1,6);% pipe_damage_data,元胞数组,存放6类行数相同的由随机抽样产生的破坏点数据
pipe_damage_data{1,1}=zeros(link_num,1); %破坏点的编号
pipe_damage_data{1,2}=cell(link_num,1); %破坏点所在管线的编号
pipe_damage_data{1,3}=zeros(link_num,1); %该管线的破坏次序
pipe_damage_data{1,4}=zeros(link_num,1); %前后破坏点的长度比例
pipe_damage_data{1,5}=zeros(link_num,1); %破坏类型，1渗漏，2断开
pipe_damage_data{1,6}=zeros(link_num,1); %破坏点处渗漏面积，m^2
link_D = zeros(link_num,1);% 管道直径mm
for i=1:link_num
    judge_interval=[0 0.2*Pf(i) Pf(i) 1];
    mid_a=rand_P(i,1)>judge_interval;
    mid_b=sum(mid_a);
    switch mid_b
        case 1 %断开
            damage_type1(j,i)=1;
            k=k+1;
            pipe_damage_data{1,1}(k,1)=k;
            pipe_damage_data{1,2}{k,1}=RRdata.PipeID{i};
            pipe_damage_data{1,3}(k,1)=1;
            pipe_damage_data{1,4}(k,1)=0.5;
            pipe_damage_data{1,5}(k,1)=2;
            pipe_damage_data{1,6}(k,1)=0.25*pi*(RRdata.Diameter_mm_(i)/1000)^2;
        case 2 %渗漏
            damage_type2(j,i)=1;
            k=k+1;
            pipe_damage_data{1,1}(k,1)=k;
            pipe_damage_data{1,2}{k,1}=RRdata.PipeID{i};
            pipe_damage_data{1,3}(k,1)=1;
            pipe_damage_data{1,4}(k,1)=0.5;
            pipe_damage_data{1,5}(k,1)=1;
            pipe_type = sum(abs(RRdata.Material{i}));
            link_D(i) = RRdata.Diameter_mm_(i);
            switch pipe_type %对于不同的管材分别对5种渗漏形式(环向松动,横向裂缝,纵向裂缝,管壁破损,管壁撕裂)的渗漏面积基于相应的发生概率求加权平均作为该管线的渗漏面积
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