function createRestartFromUciData(inFile, outFile)

%%%%%%%%%%%%%%%%%  BROKEN! Do not use or you might wipe out a file!


%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% load('MARBL_IC_3d.mat');
% 
% load(inFile);
% clear dt
% clear sursurfaceLayerThickness_MARBL
% clear time_series         % we do NOT want 3d times series here.
% bgc = rmfield(bgc, 'tendency');
% bgc = rmfield(bgc, 'state');
% getMemSize(bgc);
% oldSim = sim;
% clear sim
% sim.grd               = oldSim.grd;
% sim.const             = oldSim.const;
% % sim.num_time_steps    = oldSim.num_time_steps;
% sim.domain            = oldSim.domain;
% sim.bgc_struct_base   = oldSim.bgc_struct_base;
% getMemSize(sim);
% clear ans
% 
% save('demo_id_data', "sim","bgc", "forcing", "river_tendency", "surfaceLayerThickness_MARBL");
% 
% 
% % save('1D_data', "interior","surface", "MARBL_depth_unit");
% % clear
% grd = sim.grd;
% domain = sim.domain;
% const = sim.const;
% clear ans bgc figNum forcing ioerr marbl_constants_fname river_tendency sim
% % 
% % load '1D_data.mat';
% sim.domain = domain;
% sim.const = const;
% sim.grd = grd;
% clear domain

end