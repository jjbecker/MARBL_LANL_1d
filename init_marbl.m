function [ioerr, tracer_cnt, MARBL_depth_unit, interior, surface, time_series] = init_marbl (dt, nstep, marbl_constants_fname, lciso_on, domain)

MARBL_depth_unit = 1e+2;    % 1 meter here in cm units used by MARBL

% read settings file of choice (if any)

disp(' ')
disp('init_marbl.m: ')
ioerr = mex_marbl_driver('read_settings_file', marbl_constants_fname);

% FIXME: writing chemistry file -FROM- MARBLfails: varcount = 0 in F90 code
% ioerr = mex_marbl_driver('write_settings_file', 'new.input');

% FIXME: something as simple as changing a sczaler setting... sigh
% FIXME: Must hack out "ciso_on" line in defaults file if we set it here...
% FIXME: should read file or better ask MARBL for value of lciso_on
if lciso_on
    mex_marbl_driver('put setting', 'ciso_on = .true.'); 
end

% FIXME: if roughly 1,000 or more levels, when printing diags in MARBL F90
% "subroutine jj_print_diag", F90 variable "msg" gets so long that Matlab
% truncates it in cmd window. However, data in diag matrix appears to
% transfer correctly. Hence, only a factor if printing diags with 386x1000
% columns from F90. Not realistic issue IMHO...

% FIXME: comments in MARBL code appear to be wrong about what  units are
% initialize a single MARBL instance with a single column in it
%
% ---> MARBL source code says it uses units of km for depths
% But results indicate that only cm works!! Not (m), not (km)! Look at
% interior diag #151 to be sure there is no light below about 1,000 feet...
%
% e.g. small phyto growing at depth of 10km is obviously wrong.
%
% Whatever is correct, in Matlab code we use meters!


% Transer our grid to MARBL...
% Convert our depth from (m) to MARBL units (cm).
% Set grid level that is ocean bottom.

[ output_text, tracer_cnt, ...
    interior.forcing_cnt, interior.diag_cnt, ...
    surface.forcing_cnt, surface.diag_cnt ] ...
    = mex_marbl_driver ( 'init', ...
    domain.dzt *MARBL_depth_unit, ...
    domain.zw  *MARBL_depth_unit, ...
    domain.zt  *MARBL_depth_unit );

% initialize MARBL with kmt = full depth so we can call MEX to get diag
% names, dimesntions and so on, -before- we actually calculate anything.
mex_marbl_driver('set_depth', numel(domain.zt))

return











%% Obsolete code; left because it might be educational


% initialze forcing first so we can use CISO values to init tracers
interior.domain = domain;
[surface, interior]    = default_forcings ( surface, interior, MARBL_depth_unit, lciso_on );

% initialize everything to something very roughly like SMOW
%
% FIXME: try to create useful IC for interior, surface tracers, states...
%   run 1 YEAR simulation starting with defaults. Then use final values as
%   a "more accurate" initial condition, and then read those in rather than
%   spin up sim for 100K iterations every run

disp(' '); disp('init_marbl.m: using default states and tracers...');disp(' ');
[surface, interior] = default_states   ( surface, interior );
[surface, interior] = default_tracers  ( surface, interior, lciso_on );


% move values over to MARBL

mex_marbl_driver ( 'restore_tracers_at_surface', surface.tracer  );
mex_marbl_driver ( 'restore_tracers',            interior.tracer );

% No initialization needed for tendency, diags, and fluxes which are MARBL
% outputs but we read them to get dimensions, then pre-allocate log, so we
% can save results quickly...

interior.tracer_name   = tracer_names ( lciso_on );
surface. tracer_name   = tracer_names ( lciso_on );
interior.tracer_unit   = tracer_units ( lciso_on );
surface. tracer_unit   = tracer_units ( lciso_on );

interior.diag_name     = diag_names   ( 'interior_tendency_diags', interior.diag_cnt );
surface. diag_name     = diag_names   ( 'surface_flux_diags'     , surface. diag_cnt );
% FIXME: these are hacked to be matrix, but diags in MARBL are complex structs...
interior.diag          = mex_marbl_driver ( 'interior_tendency_diags' );
surface. diag          = mex_marbl_driver ( 'surface_flux_diags' );
interior.tendency      = mex_marbl_driver ( 'interior_tendencies' );
surface.flux           = mex_marbl_driver ( 'surface_fluxes' );
surface.sfo            = mex_marbl_driver ( 'sfo' );

interior.forcing_name  = interior_forcing_names ();
surface.forcing_name   = surface_forcing_names  (lciso_on);


% keep time series of values, everything for every time step

time_series = init_time_series(nstep, dt, lciso_on, interior, surface);

end % init_marbl.m
