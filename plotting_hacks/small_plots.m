function small_plots ( surface, interior, lciso_on, time_series )

fprintf('\n%s.n: Make a lot of little DEBUG plots ~20 (s)...\n', mfilename)

tic;

dt    = time_series.dt;
nstep = time_series.nstep;
tot_t = dt*nstep;
const.sec_d = 60*60*24;

dx = const.sec_d/dt;
t = (0:size(time_series.tracer, 3)-1) /dx;

%%
% Prove depths in MARBL are in cm: plot sunlight v. depth
% -DIAG- #151 = PAR_avg = PAR at depth

idx = 151;

fprintf('%s.m: Make a 3D plot of a PAR, say 7 days, starting at day 1...\n', mfilename);
start_day = 1;
n_days = 7;
n_cnt = floor(n_days* const.sec_d/dt);
n_start = round(max(dt, start_day* const.sec_d)/dt);
n_range = n_start:n_start +n_cnt -1;

small_data = time_series.diag(:,:,n_range);
squeeze(small_data(151,1,:)); % debug crzay mess of plot code. Check peak in 3d plot with "ans"

fig = 1;
fig = plot3dDiagTimeSeries  ( fig, small_data, interior,idx, n_cnt, dt);

%%
% Debug this monster with a tone of little plots of tracers v. time, and
% tracers v. depth, and diags also verses time and then depth
% surface tracers

tracerUnits = strcat(interior.tracer_name," ",interior.tracer_unit);

idx = 1:size(interior.tracer_name');        % plot -ALL- the tracers???
myTitle = 'Surface Tracers v. Time (d)';
myData = squeeze(time_series.tracer(:,1,:));% layer 1 is "surface"
fig = plot_log(fig, myTitle, t, myData, tracerUnits(idx), idx, false);

% surface diags

idx = 1:size(surface.diag_name);
myTitle = 'Surface Diags v. Time (d)';
myData = time_series.surface_diags;        % plot -ALL- the diags???
fig = plot_log(fig, myTitle, t, myData, surface.diag_name(idx), idx, false);

% Plot interior tracer time series

plot_layer = min(interior.domain.kmt, 3);
% plot_layer = interior.domain.kmt;

idx_int = 1:size(interior.tracer_name');
fig = plot_interior_tracers(fig, tot_t, plot_layer, idx_int, interior, time_series);

% return


my_time = 70.;        % e.g. noon day 70 or biggest we have
my_time = my_time*const.sec_d;      % e.g. day converted to sec
my_time = tot_t;
% FIXME: do NOT pick midnight (aka 0 second of day) if you graph PAR
my_time = tot_t -0.4 *const.sec_d;


idx = [ 135, 139, 151, 149, 189, 192, 196, 202, 203, 213, 212, 218, 233 ]';
fig = plot_interior_diags(fig, my_time, plot_layer, idx, 'Sample of', interior, time_series);

if lciso_on
% % works but too many plots for a demo!!!
% %     interior.diag_name
% %     idx = [ 30, 23, 24, 338, 340, 179, 180, 174 ];
% %     interior.diag_name(idx)
% %     fig = plot_interior_diags(fig, my_time, plot_layer, idx, 'POC', interior, time_series);
% % 
% %     idx = [ 327:334 369:372 385:386 ];
% %     interior.diag_name(idx)
% %     fig = plot_interior_diags(fig, my_time, plot_layer, idx, 'Diaz Diags #3', interior, time_series);
% % 
% %     idx = [  277:288,301,303,305,306,309,311,313,316,319,321,324,327,329,332,337,338,373,374,377,379,381,383,385];
% %     interior.diag_name(idx)
% %     fig = plot_interior_diags(fig, my_time, plot_layer, idx, '13C', interior, time_series);
% % 
% %     % plot_layer = 1;
% %     idx = [  277:288,301,303,305,306,309,311,313,316,319,321,324,327,329,332,337,338,373,374,377,379,381,383,385];
% %     interior.diag_name(idx)
% %     fig = plot_interior_diags(fig, my_time, plot_layer, idx, '13C', interior, time_series);
% % 
% %     myTitle = 'Glitch in 13CO2 flux when pCO2 = atm (d)';
% %     idx = [ 13, 28:31, 37:40];
% %     myData = time_series.surface_diags(:,idx);
% %     fig = plot_log(fig, myTitle, t, myData, surface.diag_name(idx), idx, false);
% % 
end

% % works but too many plots for a demo!!!
% % idx = 90:116;
% % fig = plot_interior_diags(fig, my_time, plot_layer, idx, 'Diaz Diags #1', interior, time_series);
% % 
% % idx = 249:265;
% % fig = plot_interior_diags(fig, my_time, plot_layer, idx, 'Diaz Diags #2', interior, time_series);


myTitle = 'SFO';
idx = 1:4;
myData = time_series.sfo(idx,:);
myName = surface_flux_output_names()';
fig = plot_log(fig, myTitle, t, myData, myName,idx, false);

% % works but too many plots for a demo!!!
% % % Interior tracer #18 zoo plankton C
% % % Great way to show Zoo do -NOT- move vertically during the day/night
% % small_data = time_series.tracer(n_range,:,:);
% % idx = 18;
% % fig = plot3dTracerTimeSeries( fig, small_data, interior, idx, n_cnt, dt, lciso_on);
% % 
% % % Interior tracer #46 diaz C14 does show diurnal cycle
% % if lciso_on
% %     idx = 46;
% %     fig = plot3dTracerTimeSeries( fig, small_data, interior, idx, n_cnt, dt, lciso_on);
% % end
% % 
% % % Interior tracer #4
% % idx = 4;
% % fig = plot3dTracerTimeSeries( fig, small_data, interior, idx, n_cnt, dt, lciso_on);
% % % "" but legible...
% % figure(fig);
% % plot_layer = 3;
% % foo = small_data(:,idx,plot_layer);
% % t_unit = const.sec_d;n_decimate = 1;
% % t = decimate ( ( n_range ) *dt/t_unit, n_decimate );
% % tracer_name  = interior.tracer_name(idx);
% % 
% % unit = tracer_units(lciso_on);
% % plot(t,foo);
% % title("Tracer #"+idx+" "+tracer_name+" "+'plot_layer #'+plot_layer+ ...
% %     ' depth '+interior.domain.zt(plot_layer)+" (m)",'Interpreter', 'none');
% % xlabel('time (days)')
% % ylabel(unit(idx))
% % fig = 1+(fig);
% % 

elapsedTime = toc;
fprintf('%s.m: runtime: %s (s)\n', mfilename,num2str(elapsedTime, '%1.0f'))

end % small_plots.m
