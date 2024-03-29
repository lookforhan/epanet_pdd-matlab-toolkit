function start_toolkit()
%START_TOOLKIT Loads all the EPANET-MATLAB Toolkit folder paths in MATLAB. 
%Run this function before calling 'epanet.m' and the Matlab modules.
%
% Syntax:  start_toolkit
%%
% 
%%
% 
%
% Inputs:
%    none
%
% Outputs:
%    none
%
% Example: 
%    start_toolkit
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author        : Demetrios G. Eliades, Marios Kyriakou
% Work address  : KIOS Research Center, University of Cyprus
% email         : eldemet@ucy.ac.cy
% Website       : http://www.kios.ucy.ac.cy
% Last revision : September 2016

%------------- BEGIN CODE --------------
addpath(genpath(pwd));
disp(pwd)
disp('EPANET_PDD-MATLAB Toolkit Paths Loaded.');
% path('E:\hanzhao\the_study_of_leak_model_in_epanet',path);
% path('E:\hanzhao\a-comparison-of-2-technologies-that-analyze-resilience\lib\damageNet\',path);
% path('E:\hanzhao\PlotPub\lib',path);
% path('E:\hanzhao\adjustBoxDim',path);
%------------- END OF CODE --------------


