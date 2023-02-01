function time_series = init_time_series(nstep, dt, lciso_on, interior, surface)

tracer_cnt = size(interior.tracer,1);

time_series.nstep         = nstep;
time_series.dt            = dt;
% time_series.tracer_name   = tracer_names(lciso_on);
% time_series.tracer_unit   = tracer_units(lciso_on);
% time_series.diag_name     = interior.diag_name;
% time_series.forcing_name  = interior.forcing_name;
% time_series.surface_diag_name = surface.diag_name;
% time_series.forcing_name  = interior.forcing_name;
% time_series.surface_forcing_name = surface.forcing_name;

time_series.diag          = zeros(interior.diag_cnt, size(interior.domain.zw,2), nstep);
time_series.surface_diags = zeros(surface.diag_cnt, nstep);

time_series.tracer        = zeros(tracer_cnt, size(interior.domain.zw,2), nstep);
time_series.tendency      = zeros(tracer_cnt, size(interior.domain.zw,2), nstep);

time_series.surface_flux  = zeros(tracer_cnt, nstep);
time_series.sfo           = zeros(size(surface.sfo, 2), nstep); % e.g. 4 air-sea-flux

time_series.s_forcing     = zeros(surface.forcing_cnt, nstep);
time_series.i_forcing     = zeros(interior.forcing_cnt, size(interior.domain.zw,2), nstep);

end

