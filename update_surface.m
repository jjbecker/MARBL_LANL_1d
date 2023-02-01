function [surface, interior] = update_surface ( surface, interior, skip, MARBL_depth_unit )


% FIXME: use midpoint of time step to update surface?
surface.tracer = (interior.tracer_old(:,1)' +interior.tracer(:,1)') ./2;
surface.state  = (interior.state_old (:,1)  +interior.state (:,1) ) ./2;


% Move forcing, tracer, and state data from Matlab into MARBL F90.

mex_marbl_driver ( 'restore_surface_flux_forcings',    surface.forcing );
mex_marbl_driver ( 'restore_surface_flux_saved_state', surface.state   );
mex_marbl_driver ( 'restore_tracers_at_surface',       surface.tracer  );


% Call the F90 code to compute tendency of F90 data. Does NOT move data...
%
% Sign of flux is such that negative values are OUT water layer...

status = mex_marbl_driver('surface_flux_compute');
if status
   error('MEX failed: "bad input data"??')
end


% Move data from MARBL F90 to Matlab variables...

surface.flux  = mex_marbl_driver ( 'surface_fluxes' );
surface.sfo   = mex_marbl_driver ( 'sfo' );
surface.diag  = mex_marbl_driver(  'surface_flux_diags' );
surface.state = mex_marbl_driver ( 'surface_flux_saved_state' );


% Some updates are just startup spikes, like when CISO=1 and n=1.
% To avoid confusing off by one bugs, just zero flux 0, but keep everything 
% else so we have same number of samples for flux, diags, etc.

if skip
    surface.flux = surface.flux *0;
end


% Need to know depth to convert surface flux to volume rate of change.
%
% Units of -METERS- are used in this sim.
%   convert depth here (m) to units (cm) used in MARBL

surface.tendency = surface.flux' /(interior.domain.dzt(1) * MARBL_depth_unit);


% FIXME: check flux for NaN and other errors...
% FIXME:    ...record (bad) tracer and surface_flux_forcing?
% FIXME: update global averages?

end % update_surface