% function MARBL_LANL_1d
%%
%% https://stackoverflow.com/questions/41029591/matlab-mex-not-looking-for-compiler-gfortran-on-macos?rq=1
%%
clear all  % everything
dbstop if error;

addpath ("MEX", "plotting_hacks", "namesAndUnits")

% Oversimplified trapizoid integration of a single water column.
%
% Includes an over simplified advection and diffusion model. 
% 
% MARBL is finicky about unphysical tracer or forcing values, and debugging
% MARBL crashes is difficult. So main chore here is finding a set of 
% tracers, forcings, grid spacing and so on to get a model working, 
%
% To simplify this demo, essentially all data are read from a working UCI
% 3d simulation that is based on MARBL and "transport matrices". Only a 
% handfull of ~500 MB input of that file is actually used in this demo,
% because we only want one of 7,881 water columns available. But in the
% interest of time, complete 3d data set is input and then discarded.
%
% 
%
% A 3d restart file was created for CESM 3 deg grid using a 3 hour 
% time step. If you want a different grid spacing, time step, etc you'll 
% need to adjust (many) variable to your particular needs. This is less
% obvious than it might seem; contact me if you have questions.

% Because CESM has many variable related to grid dimensions, MARBL does
% too. In addition MARBL has it's own collection of variables, forcings,
% names, units, and other arrays. Initializing all this data can distract
% from fact that once everything is initialized, time step calls 
% are pretty straight forward.

% FIXME: All though MARBL MEX was designed and tested, 3 years ago, to run
% with and without "CISO" tracers such as "C13" and "C14", that has
% been tested lately. So this Demo does NOT use CISO. To turn it on,
% essentially all tracers, forcing, time series spy data, and so on
% must be redimensioned. Not conceptually difficult but writting on
% research code to run with/out CISO proved to generate a lot of
% computer-ish hacking...

% "bgc" struct (should have) only variables like tracers but also dims
% "forcing" struct has only forcings
% "time_series" spies bgc for a single water column at every time step
% "sim" struct (should have) only variables like dt, dimensions, etc 
%       ...but it is "kitchen sink" of all stray parameters too...
% 
% In these four structs units are MKS, MARBL uses cm, and mmol/m^3, and
% other practical units for these sorts of simulations. Because MARBL
% MEX is written to run fast using hte Matlab Parallel toolbox, some
% conversion factors needed to be taken of "sim" where they belong...

% Pick an arbitrary location in world as single water column. MARBL
% operates on a single water column at a time. So it is useful to think of
% CESM grid as 7,881 water columns and 60 vertical levels. Not all grid
% levels are "wet". "kmt" is water depth of a particular water column.
% 
%   1<=kmt<=60
% 

fprintf("%s.m: Using CESM 3 deg grid vertical grid\n", mfilename)
% load('MARBL_IC_3d.mat');
load('demo_data');


getMemSize(bgc);
getMemSize(sim);

sim.dt = 1 *sim.const.sec_h;

fprintf("%s.m: time step is %d (s) or %g (h)\n", mfilename, sim.dt, round(sim.dt/3600))

num_yr = 3;

tot_t = round ( num_yr *sim.const.sec_y );
nstep = round ( tot_t /sim.dt );

figNum = 1234;
[time_series_loc ,time_series_lvl] = pick_water_column(sim,figNum);

disp(['nstep: ', num2str(nstep)]);
disp(['time step is ', num2str(sim.dt *60/sim.const.sec_h), ...
    ' (m), simulating ', num2str(tot_t /sim.const.sec_y, '%1.2f'), ...
    ' (y), hence ', num2str(round(nstep/1000,2)), ' (k) MARBL time steps'])


% FIXME: Matlab is incredibly sensitive to array dimensions and so on. 
%
% For whatever reason, making time_series a global, (while both stupid and 
% bad), makes this code run at normal speed. 
%
% Profiler indicates line 27 is problem.
% 
% So just skip all that debugging for this demo and use a global...

global time_series

%% Initialize MARBL
% define size and shape of all grids and arrays, 
% then read files of constants, and define text for output diags...

% at UCI we don't use C14 etc. MARBL MEX code works, but using c14 changes
% dimension of many variable.
% 
% FIXME: You need to create your own working "CISO" initial condition.
% 
% lciso_on = 0;   % replace sim.lciso everywhere with 1 if you use CISO

marbl_constants_fname= 'default_chemistry.input';

% initialize MEX, and save diag_cnt and forcing_cnt which is a
% variable that depends on if isotopes are being calculated.

lciso_on = 0;
[ioerr, ~, MARBL_depth_unit, interior, surface ] = init_marbl (sim.dt, nstep, marbl_constants_fname, lciso_on, sim.domain);

[ interior, surface ] = init_structs( interior, surface, bgc, sim, time_series_loc);

% save a restart file?
%
% save('demo_data', "sim","bgc", "forcing", "river_tendency", "surfaceLayerThickness_MARBL");


%% copy from a UCI restart file only data used in this single column demo

time_series = init_time_series(nstep, sim.dt, lciso_on, interior, surface);

%%

% Quick checks to see if MARBL is running, have MARBL print to Matlab command window...

disp('Check if MARBL is running: Are three 27 lines of output?');  
disp([string(surface. diag_name(1:end))])
% disp('Check if MARBL is running: Are three 312 lines of output?'); 
% disp([string(interior.diag_name(1:end))])   

%%

% Set up a trival advection...
% Use transport matrix "T" from Francois 1_d driver demo using UCI grid
%
% Need some sort of mixing or trapizoid integration will blow up, but this
% advection model is just an ad hoc scheme to get something, anything
% mixing tracers...

FT = calc_FT(interior, sim.dt);


tic
% Set bottom depth at this water column
mex_marbl_driver('set_depth', interior.domain.kmt)

% FIXME: first call to surface update can be garbage. Uninitialized var? 
% FIXME: Call update_surface  before first time step and discard result, for now...
    interior.state_old  = interior.state;
    interior.tracer_old = interior.tracer;
    ignore = 1;
    [surface, interior] = update_surface ( surface, interior, ignore, MARBL_depth_unit );
    ignore = 0;

fprintf("\n%s.m: Simulating %g (y)\n", mfilename, num_yr)
fprintf("%s.m: Simulation time will be very approxiamtely %g (s)...\n", mfilename, num_yr *5) % ad hoc
fprintf("%s.m: ...plus another ~30 seconds for making many hacked plots of result\n\n", mfilename)
for n=1:nstep

    % FIXME: use midpoint of time step for surface flux update ???
    % need to save tracers and state before update.

    interior.state_old  = interior.state;
    interior.tracer_old = interior.tracer;


    % update forcing of interior and surface every time step...

    [surface, interior] = update_forcing ( sim.dt*(n-1), surface, interior );

    % update interior and surface forcing.
    % FIXME: use midpoint of time step for surface flux update ???

    interior = update_interior ( interior );
    ignore = 0;
    [surface, interior] = update_surface ( surface, interior, ignore, MARBL_depth_unit);

    % add suface tendency to top of interior tendency
    
    tendency = interior.tendency;
    tendency(:,1) = tendency(:,1) +surface.tendency;


    % MUST zero garbage below ocean bottom! Simple advection model will
    % spread that stuff all over. 
    % Check for NaN while we are at it.
    tendency( :, interior.domain.kmt+1:end ) = 0; 
    if sum(~isfinite(tendency),'all')
        keyboard
    end


    % trapizoid rule time step.
    %
    % Add fake diffusion using "toy" advection model from Francois. Be sure
    % that result does NOT have any garbage below ocean bottom (kmt)
    
    interior.tracer = interior.tracer +sim.dt*tendency;

    interior.tracer = mfactor (FT, interior.tracer')';
    
    % zero garbage below ocean bottom. Check for NaN while we are at it.
    % interior.tracer( :, interior.domain.kmt+1:end ) = 0;
    % if sum(~isfinite(interior.tracer),'all')
    %     keyboard
    % end


    % record tracers at all levels at all times

%      [time_series] = update_time_series (time_series, n, surface, interior);
    update_time_series (n, surface, interior);

end

% FIXME: do NOT shutdown MARBL until Matlab is done printing
%   -> need a few seconds for Matlab to finish updating command window if
%   printing a huge number of levels could take 10 sec...


elapsedTime = toc;
total_yr = tot_t/sim.const.sec_y;
disp(' ');
disp(['Runtime: ', num2str(elapsedTime, '%1.0f'),' (s) or ', num2str(elapsedTime/60, '%1.1f'), ' (m)'])
disp(['Runtime per sim year: ', num2str(elapsedTime/total_yr, '%f'), ' (s/sim_yr)'])
disp(['Runtime per iteration: ',           num2str(elapsedTime/nstep*1000, '%1.1f'),                    ' (ms)'])
% disp(['Runtime per iteration per level: ', num2str(elapsedTime/nstep/size(interior.domain.zw,2)*1000, '%1.2f'), ' (ms)'])


%%
% As a learning and debug tool dump 1000's of numbers from MARBL
%
% Check (ugly code) in these files for MANY things that are/can be used. 
%   mex_marbl_driver in Matlab calls    MEX/mex_marbl_driver.F90
%   MEX/mex_marbl_driver.F90 calls      MEX/marbl_interface_wrapper_mod.F90
% 
disp ' '; disp 'Have MARBL print stuff to unit 6, but display it here, to see if everything is still running...';disp ' '
mex_marbl_driver('print_sfo');
% mex_marbl_driver('print_surface_flux_forcings');
% mex_marbl_driver('print_surface_fluxes');
% mex_marbl_driver('print_surface_diags');% DEBUG

% mex_marbl_driver('print_interior_tendency_forcings');
% mex_marbl_driver('print_interior_tendencies');
% mex_marbl_driver('print_interior_tendency_diags');  % DEBUG

% mex_marbl_driver('print_marbl');      % DEBUG prints a HUGE amount!

%%
% As a learning and debug tool make literally 100's of tiny junk plots
%
% Super useful for bring up: mid latitude surface location plots should
% have obvious diural cycles and exponential fall off with depth...

small_plots( surface, interior, lciso_on, time_series );
plot_3D(100, interior, time_series);
pause(1); 
autoArrangeFigures();           % use all of screen
% autoArrangeFigures(0,0,2);      % useful if you have 2 or more displays
% disp('Saving all small plots. Takes about 10 (s)...'); saveFigs(pwd);


%%
% FIXME: do NOT shutdown MARBL until Matlab is done printing
%   -> need a few seconds for Matlab to finish updating command window if
%   printing a huge number of levels...
%
disp('Shutting down MEX in 3 (s)...'); pause(3);
mex_marbl_driver('shutdown');

disp('...success!');
