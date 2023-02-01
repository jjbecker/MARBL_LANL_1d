function interior = update_interior ( interior )

% Move forcing, tracer, and state data from Matlab into MARBL F90.

mex_marbl_driver ( 'restore_interior_tendency_forcings',    interior.forcing );
mex_marbl_driver ( 'restore_tracers',                       interior.tracer  );
mex_marbl_driver ( 'restore_interior_tendency_saved_state', interior.state   );


% Call the F90 code to compute tendency of F90 data. Does NOT move data...

status = mex_marbl_driver('interior_tendency_compute');
if status
   error('MEX failed: "bad input data"??')
end

% Move data from MARBL F90 to Matlab variables...

interior.tendency = mex_marbl_driver ( 'interior_tendencies' );
interior.diag     = mex_marbl_driver ( 'interior_tendency_diags');
interior.state    = mex_marbl_driver ( 'interior_tendency_saved_state' );

% FIXME: check for NaN and other errors.
% FIXME: record bad tracer and flux, ignore them, or just stop ???
% FIXME: update global averages ???

end % update_interior