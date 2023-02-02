function fig = plot_3D(fig, interior, time_series)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

tic;

fprintf("%s.m: Making 3D plots which are VERY slow for long sims; e.g. 10 yr w/1 hr dt -> ~100k time steps to plot\n", mfilename)
dt      = time_series.dt;
nstep   = time_series.nstep;

% 3d plots
% idx: 7 = O2, 8 = DIC, 12 = DOC, 19 = spChl, 24 = diatChl, 29 = diazChl
% idx: 33 = DI13C, 34 = DO13Ctot, 37 = zootot13C, 39 = sp13C, 41 = spCa13CO3, 43 = diat13C 45 = diaz13C
% idx: 35 = DI14C, 36 = DO14Ctot, 38 = zootot14C, 40 = sp14C, 42 = spCa14CO3, 44 = diat14C 46 = diaz14C

% first plot TRACERS

idx = [12];
lciso_on = 0;
if lciso_on == 1
    idx = [idx 33:34 37 39 41 43 45];
    idx = [idx 35:36 38 40 42 44 46];
end

for i = idx
    fig = plot3dTracerTimeSeries(fig, time_series.tracer, interior, i, nstep, dt, lciso_on);
end


% Now plot DIAGS, only differene is arg #2 of plot3dDiagTimeSeries

% idx = [7 8 12 19 24 29];
idx = [213];

lciso_on = 0;
if lciso_on == 1
    idx = [idx 33:34 37 39 41 43 45];
    idx = [idx 35:36 38 40 42 44 46];
end

for i = idx
    fig = plot3dDiagTimeSeries(fig, time_series.diag, interior, i, nstep, dt);
end

elapsedTime = toc;
fprintf('%s.m: runtime: %s (s)\n', mfilename,num2str(elapsedTime, '%1.0f'))
end
