function myFig = plot_interior_tracers(myFig, my_time, plot_layer, idx, interior, time_series)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

dt      = time_series.dt;
nstep   = time_series.nstep;
% tot_t   = dt*nstep;
dx      = 60*60*24/dt;
t       = (0:size(time_series.tracer, 3)-1) /dx;


plot_depth = interior.domain.zt(plot_layer);

iter = max( 1, min(round(my_time/dt),nstep));

nameUnits = strcat(interior.tracer_name," ",interior.tracer_unit);

% plot data v. time

myTitle = sprintf('Interior Tracers v. Time(d) @level %d, depth = %d(m)', ...
    plot_layer, round(plot_depth));
myData = squeeze(time_series.tracer(idx, plot_layer, :));
myFig = plot_log(myFig, myTitle, t, myData, nameUnits(idx), idx, false);


% plot data v. depth

myTitle = sprintf('Interior Tracers v. Depth (m) @day %G, iteration = %d', ...
    round(my_time/60*60*24,2), iter);
myData = squeeze(time_series.tracer(idx, :,iter));
myDepth = interior.domain.zt;
myFig = plot_log(myFig, myTitle, myDepth, myData, nameUnits(idx), idx, true);

end
