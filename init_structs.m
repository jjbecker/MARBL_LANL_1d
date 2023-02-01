function [ interior, surface ] = init_structs( interior, surface, bgc, sim, time_series_loc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% bottom depth
% tmp_int = interior;
% tmp_surf = surface;

%% grid dimensions aka "domain"
interior.domain.zt  = sim.domain.zt;
interior.domain.zw  = sim.domain.zw;
interior.domain.dzt = sim.domain.dzt;
interior.domain.dzw = sim.domain.dzw;

interior.domain.kmt =  bgc.kmt(time_series_loc      );

% FIXME: these are hacked to be matrix here, but diags in MARBL are structs...
interior.forcing    = squeeze( bgc.forcing      (time_series_loc,:,:) );
interior.state      = squeeze( bgc.state        (time_series_loc,:,:) );
interior.tracer     = squeeze( bgc.tracer       (time_series_loc,:,:) );

surface. forcing      = squeeze( bgc.surf_forcing (time_series_loc,:,:) );
surface. state        = interior.state (:,1);
surface. tracer       = interior.tracer(:,1);
surface. sfo          = mex_marbl_driver ( 'sfo' );
surface. river_flux   = squeeze( bgc.river_flux   (time_series_loc,:,:) );

%%
% %% plotting needs to know all kinds of names and stuff
%
interior.tracer_name  = sim.bgc_struct_base.name.tracer;
interior.tracer_unit  = sim.bgc_struct_base.unit.tracer;
interior.forcing_name = sim.bgc_struct_base.name.forcing;

%%
% This old MATLAB code has some different shapes than CESM

interior.forcing      = interior.forcing';
interior.state        = interior.state';
interior.tracer       = interior.tracer';

surface. forcing      = surface. forcing';
surface. tracer       = surface. tracer';
surface. river_flux   = surface. river_flux';

%% plotting needs to know all kinds of names and stuff

% MARBL already knows (what it thinks) are corrent names and units

interior.diag_name     = diag_names   ( 'interior_tendency_diags', interior.diag_cnt );
surface. diag_name     = diag_names   ( 'surface_flux_diags'     , surface. diag_cnt );

%% River flux (if used) is done in CESM; -NOT- done in MARBL

surface. river_flux_name=sim.bgc_struct_base.name.river_flux;

%% Find any NaN and set them to zero. 

interior.  state = zero_NAN( interior.  state );
interior. tracer = zero_NAN( interior. tracer );
interior.forcing = zero_NAN( interior.forcing );

surface.   state = zero_NAN( surface.   state );
surface.  tracer = zero_NAN( surface.  tracer );
surface. forcing = zero_NAN( surface. forcing );

%% Zero below the bottom

%FIXME: zeroing NaN should solve issues with garabge between ocean bottom 
% and bottom of grid. 
% But no guarantee...

end

% surface. diag_name    = surface. diag_name';
% interior.tendency_name = sim.bgc_struct_base.name.tendency;
% interior.state_name    = sim.bgc_struct_base.name.state;
% surface. sfo_names     = sim.bgc_struct_base.name.sfo;
% interior.diag_name     = sim.bgc_struct_base.name.diag;
% surface. diag_name     = sim.bgc_struct_base.name.surf_diag;
%
% interior.tendency     = squeeze( bgc.tendency     (time_series_loc,:,:) );
% interior.tendency   = interior.tendency';
% interior.diag_name    = sim.bgc_struct_base.name.diag;
% interior.diag         = mex_marbl_driver ( 'interior_tendency_diags' );
% interior.tendency     = mex_marbl_driver ( 'interior_tendencies' );
% interior.forcing_name = sim.bgc_struct_base.name.forcing;
% interior.forcing_cnt  = size(interior.forcing_name,2);
% interior.diag_cnt     = size(interior.diag_name,   2);
% surface. tracer_name  = interior.tracer_name;
% surface. tracer_unit  = interior.tracer_unit;
% surface. diag_name    = sim.bgc_struct_base.name.surf_diag;
% surface. diag         = mex_marbl_driver ( 'surface_flux_diags' );
% surface. flux         = mex_marbl_driver ( 'surface_fluxes' );
% surface. forcing_name = sim.bgc_struct_base.name.surf_forcing;

