classdef EMT_add_damage < handle
    %EMT_add_damage 此处显示有关此类的摘要
    %   利用 Epanet-Matlab-Tool增加破坏节点
    % How to run:
    % d = EMT_add_damage('net03.inp');
    % d.add_info({'3';'4'},[0.2,0.4,0.4;0.5,0.5,0],{'L','B';'B','N'},[100,0;0,0])
    % d.add2net;
    % d.saveInpFile('net03-1.inp')
    % d.solveH
    % d.preReport('net03-1');
    % d.closeNetwork;
    % d.delete
    
    properties
        Epanet
    end
    
    methods
        function obj = EMT_add_damage(inpfile)
            %EMT_add_damage 构造此类的实例
            %   此处显示详细说明
            obj.Epanet = epanet(inpfile);
        end
        
        function delete(obj)
            obj.Epanet.unload;
        end
    end
    methods % add information
        function init(obj)
            obj.PipeNameID = []; % the ID of the pipes which will be changed.
            obj.FromNodeNameID = [];
            obj.ToNodeNameID = [];
            obj.NewNode = [];
            obj.NewIntervalPipe = [];
        end
        function add_info(obj,pipeID,rateLength,damageType,equalDiameter)
            % check the formates of the input parameters
            obj.init();
            check_add_info(pipeID,rateLength,damageType,equalDiameter)
            obj.PipeNameID = pipeID;
            pipeIndex = obj.Epanet.getLinkIndex(pipeID);
            pipeDiameter = obj.Epanet.getLinkDiameter(pipeIndex); % pipeIndex must be 1*n format;
            pipeLengths = obj.Epanet.getLinkLength(pipeIndex);
            pipeRoughnessCoeff = obj.Epanet.getLinkRoughnessCoeff(pipeIndex);
            pipeNodesIndexAll = obj.Epanet.getLinkNodesIndex; % Retrieve the Indexes of the from/to nodes of all links;
            fromNodeIndex = pipeNodesIndexAll(pipeIndex,1);
            toNodeIndex = pipeNodesIndexAll(pipeIndex,2);
            nodeElevationsAll = obj.Epanet.getNodeElevations;
            nodeCoordinatesAll = obj.Epanet.getNodeCoordinates;
            fromNodeElevation = nodeElevationsAll(fromNodeIndex);
            fromNodeCoordinationX = nodeCoordinatesAll{1}(fromNodeIndex);
            fromNodeCoordinationY = nodeCoordinatesAll{2}(fromNodeIndex);
            toNodeElevation = nodeElevationsAll(toNodeIndex);
            toNodeCoordinationX = nodeCoordinatesAll{1}(toNodeIndex);
            toNodeCoordinationY = nodeCoordinatesAll{2}(toNodeIndex);
            obj.FromNodeNameID = obj.Epanet.getNodeNameID(fromNodeIndex');
            obj.ToNodeNameID = obj.Epanet.getNodeNameID(toNodeIndex');
            
            for i = 1:numel(pipeID)
                if sum(rateLength(i,:))==1
                    newNodeNum = sum(rateLength(i,:)>0)-1;
                else
                    newNodeNum = sum(rateLength(i,:)>0);
                end
                sumRateLength = cumsum(rateLength,2);% 累加
                obj.NewNode(i).number = newNodeNum;
                
                obj.NewNode(i).elevation = (1-sumRateLength(i,1:newNodeNum)).*fromNodeElevation(i)+sumRateLength(i,1:newNodeNum).*toNodeElevation(i);
                obj.NewNode(i).coordinationX = (1-sumRateLength(i,1:newNodeNum)).*fromNodeCoordinationX(i)+sumRateLength(i,1:newNodeNum).*toNodeCoordinationX(i);
                obj.NewNode(i).coordinationY = (1-sumRateLength(i,1:newNodeNum)).*fromNodeCoordinationY(i)+sumRateLength(i,1:newNodeNum).*toNodeCoordinationY(i);
                
                obj.NewIntervalPipe(i).Length = rateLength(i,:).*pipeLengths(i);
                obj.NewIntervalPipe(i).Diameter = pipeDiameter(i);
                obj.NewIntervalPipe(i).RoughnessCoeff = pipeRoughnessCoeff(i);
                
                obj.NewNode(i).equalDiameter = equalDiameter(i,:);
                obj.NewNode(i).damageType = damageType(i,:);
            end
        end
    end
    properties
        PipeNameID = [] % the ID of the pipes which will be changed.
        FromNodeNameID = []
        ToNodeNameID = []
        NewNode = []
        NewIntervalPipe = []
    end
    methods % add to net
        function add2net(obj)
            % add new components into the network
            % 2R2N2C is used to model break 
            % 1R1N1C is used to model leak
            pipeNumber = numel(obj.PipeNameID);
            for i = 1:pipeNumber
                damageNumber = obj.NewNode(i).number;
                fromNode = cell(damageNumber+1,1);
                toNode = cell(damageNumber+1,1);
                R1_id = cell(damageNumber,1);
                R2_id = cell(damageNumber,1);
                C1_id = cell(damageNumber,1);
                C2_id = cell(damageNumber,1);
                N1_id = cell(damageNumber,1);
                N2_id = cell(damageNumber,1);
                P1_id = cell(damageNumber+1,1);
                fromNode{1} = obj.FromNodeNameID{i};
                toNode{end} = obj.ToNodeNameID{i};
                
                R1_index = zeros(damageNumber,1);
                R2_index = zeros(damageNumber,1);
                N1_index = zeros(damageNumber,1);
                N2_index = zeros(damageNumber,1);
                C1_index = zeros(damageNumber,1);
                C2_index = zeros(damageNumber,1);
                P1_index = zeros(damageNumber,1);
                for j = 1:damageNumber
                    damageTypeCode = sum(abs(obj.NewNode(i).damageType{j}));
                    switch damageTypeCode
                        case 76 % 'L' for leak
                            R1_id{j} = [obj.Prefix_R1,obj.PipeNameID{i},obj.Postfix_leak,num2str(j)];
                            R2_id{j} = R1_id{j};
                            N1_id{j} = [obj.Prefix_N1,obj.PipeNameID{i},obj.Postfix_leak,num2str(j)];
                            N2_id{j} = N1_id{j};
                            C1_id{j} = [obj.Prefix_C1,obj.PipeNameID{i},obj.Postfix_leak,num2str(j)];
                            C2_id{j} = C1_id{j};
                            
                            R1_index(j) = obj.Epanet.addNodeReservoir(R1_id{j});
                            obj.Epanet.setNodeCoordinates(R1_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(R1_index(j),obj.NewNode(i).elevation(j));
                            
                            N1_index(j) = obj.Epanet.addNodeJunction(N1_id{j});
                            obj.Epanet.setNodeCoordinates(N1_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(N1_index(j),obj.NewNode(i).elevation(j));
                            
                            C1_index(j) = obj.Epanet.addLinkPipeCV(C1_id{j},N1_id{j},R1_id{j});
                            obj.Epanet.setLinkDiameter(C1_index(j),obj.NewNode(i).equalDiameter(j));
                            obj.Epanet.setLinkLength(C1_index(j),obj.LengthDefault);
                            obj.Epanet.setLinkRoughnessCoeff(C1_index(j),obj.RoughnessCoeff_Leak);
                            obj.Epanet.setLinkMinorLossCoeff(C1_index(j),obj.xi);
                        case 66 % 'B' for break
                            R1_id{j} = [obj.Prefix_R1,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            R2_id{j} = [obj.Prefix_R2,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            N1_id{j} = [obj.Prefix_N1,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            N2_id{j} = [obj.Prefix_N2,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            C1_id{j} = [obj.Prefix_C1,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            C2_id{j} = [obj.Prefix_C2,obj.PipeNameID{i},obj.Postfix_break,num2str(j)];
                            
                            R1_index(j) = obj.Epanet.addNodeReservoir(R1_id{j});
                            obj.Epanet.setNodeCoordinates(R1_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(R1_index(j),obj.NewNode(i).elevation(j));
                            R2_index(j) = obj.Epanet.addNodeReservoir(R2_id{j});
                            obj.Epanet.setNodeCoordinates(R2_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(R2_index(j),obj.NewNode(i).elevation(j));
                            
                            N1_index(j) = obj.Epanet.addNodeJunction(N1_id{j});
                            obj.Epanet.setNodeCoordinates(N1_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(N1_index(j),obj.NewNode(i).elevation(j));
                            N2_index(j) = obj.Epanet.addNodeJunction(N2_id{j});
                            obj.Epanet.setNodeCoordinates(N2_index(j),[obj.NewNode(i).coordinationX(j),obj.NewNode(i).coordinationY(j)]);
                            obj.Epanet.setNodeElevations(N2_index(j),obj.NewNode(i).elevation(j));
                            
                            C1_index(j) = obj.Epanet.addLinkPipeCV(C1_id{j},N1_id{j},R1_id{j});
                            obj.Epanet.setLinkDiameter(C1_index(j),obj.DiameterDefault);
                            obj.Epanet.setLinkLength(C1_index(j),obj.LengthDefault);
                            obj.Epanet.setLinkRoughnessCoeff(C1_index(j),obj.RoughnessCoeff_Break);
                            C2_index(j) = obj.Epanet.addLinkPipeCV(C2_id{j},N2_id{j},R2_id{j});
                            obj.Epanet.setLinkDiameter(C2_index(j),obj.DiameterDefault);
                            obj.Epanet.setLinkLength(C2_index(j),obj.LengthDefault);
                            obj.Epanet.setLinkRoughnessCoeff(C2_index(j),obj.RoughnessCoeff_Break);
                            
                        case 78 % 'N' for Nan
                        otherwise % someting else
                            disp('something wrong in damageType');
                            keyboard
                            return
                    end
                    toNode{j} = N1_id{j};
                    fromNode{j+1} = N2_id{j};
                    P1_id{j} = [obj.Prefix_P1,fromNode{j},'-',toNode{j}];
                    P1_index(j) = obj.Epanet.addLinkPipe(P1_id{j},fromNode{j},toNode{j});
                    obj.Epanet.setLinkDiameter(P1_index(j),obj.NewIntervalPipe(i).Diameter);
                    obj.Epanet.setLinkLength(P1_index(j),obj.NewIntervalPipe(i).Length(j));
                    obj.Epanet.setLinkRoughnessCoeff(P1_index(j),obj.NewIntervalPipe(i).RoughnessCoeff);
                    if j == damageNumber
                        P1_id{j+1} = [obj.Prefix_P1,fromNode{j+1},'-',toNode{j+1}];
                        P1_index(j+1) = obj.Epanet.addLinkPipe(P1_id{j+1},fromNode{j+1},toNode{j+1});
                        obj.Epanet.setLinkDiameter(P1_index(j+1),obj.NewIntervalPipe(i).Diameter);
                        obj.Epanet.setLinkLength(P1_index(j+1),obj.NewIntervalPipe(i).Length(j+1));
                        obj.Epanet.setLinkRoughnessCoeff(P1_index(j+1),obj.NewIntervalPipe(i).RoughnessCoeff);
                    end  
                end
            end
            obj.closePipe;
        end
    end
    properties % properties for adding to net
        mu = 0.62;
        xi 
        C = 4427;
        LengthDefault = 0.01; % m
        DiameterDefault = 99999; % mm
        RoughnessCoeff_Break = 140;
        RoughnessCoeff_Leak = 1e6;
        Postfix_leak = '-L';
        Postfix_break = '-B';
        Prefix_R1 = 'R1-';
        Prefix_R2 = 'R2-'; 
        Prefix_N1 = 'N1-'
        Prefix_N2 = 'N2-'
        Prefix_P1 = 'P1-'
        Prefix_C1 = 'C1-'
        Prefix_C2 = 'C2-'
    end
    methods % get
        function xi = get.xi(obj)
            xi = obj.mu^(-2);
        end
    end
    methods % basic functions
        function closePipe(obj)
            % Close pipes by the pipe name ID;
            P_index = obj.Epanet.getLinkIndex(obj.PipeNameID);
            pipeNumber = numel(P_index);
            value = zeros(pipeNumber,1);
            obj.Epanet.setLinkInitialStatus(P_index,value);
            obj.Epanet.setLinkStatus(P_index,value);
        end
        function saveInpFile(obj,inpFileName)
            obj.Epanet.saveInputFile(inpFileName);
        end
        function preReport(obj,reportName)
            obj.Epanet.setReportFormatReset
            obj.Epanet.setReport(['FILE  Report-',reportName,'.txt']);
            obj.Epanet.setReport('NODES ALL');
            obj.Epanet.setReport('LINKS ALL');
            obj.Epanet.writeReport;
        end
        function closeNetwork(obj)
            obj.Epanet.closeNetwork;
        end
        function solveH(obj)
            obj.Epanet.solveCompleteHydraulics;
            obj.Epanet.saveHydraulicsOutputReportingFile;
        end
        function addJunction(obj,ID,elevation,coordination)
            % add junction
            % example:
            % obj.addJunction('2',5,[2,4])
            index = obj.Epanet.addNodeJunction(ID);
            obj.Epanet.setNodeElevations(index,elevation);
            obj.Epanet.setNodeCoordinates(index,coordination);
        end
        function addEmitter(obj,ID,elevation,coordination,coefficient)
            % add junction with emitter coefficient
            % example:
            % obj.addEmitter('2',5,[2,4],7.3)
            obj.addJunction(ID,elevation,coordination);
            index = obj.Epanet.getNodeIndex(ID);
            obj.Epanet.setNodeEmitterCoeff(index,coefficient);
        end
        function addReservoir(obj,ID,elevation,coordination)
            % add reservoir
            % example:
            % obj.addReservoir('2',5,[2,4])
            index = obj.Epanet.addNodeReservoir(ID);
            obj.setNodeElevations(index,elevation);
            obj.setNodeCoordinates(index,coordination);
        end
        function addPipe(obj,ID,fromNode,toNode,length,diameter,roughnessCoeff)
            % add a normal pipe link
            % example:
            % obj.addPipe('3','1','2',100,300,130)
            index = obj.Epanet.addLinkPipe(ID,fromNode,toNode);
            obj.Epanet.setLinkLength(index,length);
            obj.Epanet.setLinkDiameter(index,diameter);
            obj.Epanet.setLinkRoughnessCoeff(index,roughnessCoeff);
        end
        function addPipeCV(obj,ID,fromNode,toNode,length,diameter,roughnessCoeff)
            % add a normal pipe with check valve
            % example:
            % obj.addPipeCV('3','1','2',100,300,130)
            index = obj.Epanet.addLinkPipeCV(ID,fromNode,toNode);
            obj.Epanet.setLinkLength(index,length);
            obj.Epanet.setLinkDiameter(index,diameter);
            obj.Epanet.setLinkRoughnessCoeff(index,roughnessCoeff);
        end
    end
end
        function check_add_info(pipeID,rateLength,damageType,equalDiameter)
            if numel(pipeID)~=numel(rateLength(:,1))
                whos('pipeID');whos('rateLength')
                disp('error: the pipeID and rateLength are discordant!')
                return
            end
            if numel(pipeID)~=numel(damageType(:,1))
                whos('pipeID');whos('damageType')
                disp('error: the pipeID and damageType are discordant!')
                return
            end
            if numel(pipeID)~=numel(equalDiameter(:,1))
                whos('pipeID');whos('equalDiameter')
                disp('error: the pipeID and equalDiameter are discordant!')
                return
            end
            if numel(damageType(1,:))~=numel(equalDiameter(1,:))
                whos('damageType');whos('equalDiameter')
                disp('error: the damageType and equalDiameter are discordant!')
                return
            end
            if ~iscell(pipeID)
                whos('pipeID');
                disp('pipeID should be cell')
                return
            end
            if ~iscell(damageType)
                whos('damageType');
                disp('damageType should be cell');
                return
            end
        end
