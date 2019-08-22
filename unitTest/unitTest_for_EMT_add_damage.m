classdef unitTest_for_EMT_add_damage < matlab.unittest.TestCase
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    %   How to run
    %   t = unitTest_for_EMT_add_damage()
    %   t.run
    properties
        obj
    end
    
    methods(TestClassSetup)
        function create_epanet_pdd(testCase)
            testCase.obj = EMT_add_damage('net03.inp');
            testCase.verifyEqual(4427,testCase.obj.C);
        end
    end
    methods(Test)
        function test_lib(testCase)
            test = libisloaded('epanet2');
            testCase.verifyTrue(test);
        end
        function test_add_info_a(testCase)
            testCase.obj.add_info({'3';'4'},[0.2,0.4,0.4;0.5,0.5,0],{'L','B';'B','N'},[100,0;0,0])
            testCase.verifyEqual(2,testCase.obj.NewNode.number);
        end
        function test_add_info_b(testCase)
            testCase.obj.add_info({'3';'5'},[0.2,0.4,0.4;0.5,0.5,0],{'L','B';'B','N'},[200,0;0,0]);
            testCase.verifyEqual(200,testCase.obj.NewNode(1).equalDiameter(1));
%             testCase.obj.
        end
        function test_add_info_c(testCase)
            testCase.obj.add_info({'2'},[0.5,0.5],{'L'},100);
            testCase.verifyEqual(1,testCase.obj.NewNode.number);
        end

    end
    methods(TestClassTeardown)
        function unload(testCase)
            testCase.obj.delete
        end
    end
    methods(TestMethodSetup)
    end
    methods(TestMethodTeardown)
    end
end

