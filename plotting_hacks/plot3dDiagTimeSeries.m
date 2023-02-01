function fig = plot3dDiagTimeSeries(myFig, tracer, interior, idx, nstep, dt, lciso_on)

diag_name    = interior.diag_name(idx);
domain       = interior.domain;

figure(myFig);
clf(myFig)

% plot shows days

t_unit = 60*60*24; % s/day

% Decimate time from seconds into "day". 

% n_decimate = max( 1, round(nstep /t_unit) );

% That still might not be enough to make plot legible
% Decimate ~ "nz"

n_decimate = 1;
% n_decimate = max( 1, round(nstep/size(interior.domain.zw,2)) );

t = decimate ( ( 1:nstep ) *dt/t_unit, n_decimate );

% depths from "middle of layer" to top. Dimension "nz"

depth = ( domain.zt ); % (m)

% Make the "meshgrid" that "surf" plot needs

[X,Y] = meshgrid ( t, depth );

% Selcted the tracer of interest

data = (( squeeze ( tracer(idx,:,:) ) )); % data(depth_idx,time_idx)

% unit = tracer_units(lciso_on);

% decimate,  data to match time
% 
% decimation filters the data, so it is a little slow
%
% downsample does not filter, it is fast, could alias
% 
% Z = downsample ( data', n_decimate )';

Z = zeros(size(interior.domain.zw,2), nstep);
for i = 1:size(interior.domain.zw,2)
    Z(i,:) = decimate ( data (i, :), n_decimate );
end

surf(X,Y,Z, 'EdgeColor', 'none');

hold on
view(3)
xlabel('time (days)')
ylabel('depth(m)')
zlabel(diag_name, 'Interpreter', 'none');
a = colorbar; a.Label.Interpreter = 'none'; a.Label.String = diag_name;
title("-DECIMATED- Ocean Interior Diag #"+idx+" "+diag_name, 'Interpreter', 'none');
fig = myFig +1;
