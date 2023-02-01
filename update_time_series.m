% FIXME: Matlab is incredibly sensitive to array dimensions and so on. 
%
% For whatever reason, making time_series a global, (while both stupid and 
% bad), makes this code run at normal speed. 
%
% Profiler indicates line 27 is problem.
% 
% So just skip all that debugging for this demo and use a global...

function update_time_series (n, surface, interior)
global time_series
% function [time_series] = update_time_series (time_series, n, surface, interior)

time_series.tracer        (:, :, n) = interior.tracer;
time_series.tendency      (:, :, n) = interior.tendency;
% this is air-sea flux converted/ Already added to interior tendency.
time_series.surface_flux  (:, n)    = surface.flux' ;   

time_series.sfo           (:, n)    = surface.sfo;      % -this- is sea->air gas flux

% The diags are large, hence slow to transfer. Saving these monsters adds
% 50% to run time!

time_series.diag          (:, :, n) = interior.diag;
time_series.surface_diags (:, n)    = surface.diag';

time_series.s_forcing     (:, n)    = surface .forcing;
time_series.i_forcing     (:, :, n) = interior.forcing(:, :);

end
