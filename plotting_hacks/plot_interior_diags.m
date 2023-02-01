function myFig = plot_interior_diags(myFig, my_time, plot_layer, idx, name, interior, time_series)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dt      = time_series.dt;
nstep   = time_series.nstep;
% tot_t   = dt*nstep;
dx      = 60*60*24/dt;
t       = (0:size(time_series.tracer, 3)-1) /dx;

plot_depth = interior.domain.zt(plot_layer);

iter = max( 1, min(round(my_time/dt),nstep));

% plot data v. time

myTitle = sprintf(append(name,' Interior Diags v. Time(d) @level %d, depth = %d(m)'), ...
    plot_layer, round(plot_depth));
myData = squeeze(time_series.diag(idx, plot_layer,:));
plot_log(myFig, myTitle, t, myData, interior.diag_name(idx), idx, false);
myFig = myFig +1;

% plot data v. depth

myTitle = sprintf(append(name,' Interior Diags v. Depth (m) @day %G, iteration = %d'),...
    round(my_time/60*60*24,2), iter);
myData = squeeze(time_series.diag(idx, :,iter));
myDepth = interior.domain.zt;
plot_log(myFig, myTitle, myDepth, myData, interior.diag_name(idx), idx, true);

myFig = myFig +1;

end
