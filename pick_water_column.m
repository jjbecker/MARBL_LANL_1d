function [time_series_loc ,time_series_lvl] = pick_water_column(sim,figNum)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Pick some particular water column, say east of Argentina, to simulate as 
% a single column. Use forcing and initial tracer values from there. Many 
% ways to define this location. In 3d sim it is water parcel that we 
% collect a time series of...

%   Water column #7462 of 7881 in CESM grid. 
%   On water level 4 of 46 water levels.
% 
%   So CESM indices for water column and it's BOTTOM LEVEL "kmt" are
% 
%   (loc,lvl) = (7462, 4)
%
%   loc = 7462
%       = (iLat,iLon, kmt)  % kmt is bottom depth, not grd limit
%       = (20,95,46) 
%       = (-45.7N, -58.3E, 1.969km)
%
%   Spy level, aka "time_series" is on level 4 of 46 "wet" levels
% 
%       = (-45.7N, -58.3E,35.0 m)
%
% Remember depth of water is NOT grid bottom, or "spy level"...


% You can pick water water column and spy depth you want but be sure water 
% level being plotted in "wet" !!!
% 
% pick a water column and depth for spy using CESM grid indices and plot 
% geographical location

% CESM grid is unequally spaced; so it hard to guess iLat, iLon, from real
% lat and lon, but iterate by hand a few times. The largest amount of
% stretching is at the north pole.
%

% % International dateline at equator
iLat = 50;
iLon = 61;

% East of Argentina
% iLat = 20;
% iLon = 95;

%%

time_series_loc = coordTransform_xyz2fp(iLat, iLon, 1, sim);
time_series_lvl = 13;

% Pick some particular water column, say east of Argentina, to simulate as 
% a single column. Use forcing and initial tracer values from there. Many 
% ways to define this location. In 3d sim it is water parcel that we 
% collect a time series of...

%   Water column #7462 of 7881 in CESM grid. 
%   On water level 4 of 46 water levels.
% 
%   So CESM indices for water column and it's BOTTOM LEVEL "kmt" are
% 
%   (loc,lvl) = (7462, 4)
%
%   loc = 7462
%       = (iLat,iLon, kmt)  % kmt is bottom depth, not grd limit
%       = (20,95,46) 
%       = (-45.7N, -58.3E, 1.969km)
%
%   Spy level, aka "time_series" is on level 4 of 46 "wet" levels
% 
%       = (-45.7N, -58.3E,35.0 m)
%
% Remember depth of water is NOT grid bottom, or "spy level"...


% You can pick water water column and spy depth you want but be sure water 
% level being plotted in "wet" !!!
% 
% pick a water column and depth for spy using CESM grid indices and plot 
% geographical location

% CESM grid is unequally spaced; so it hard to guess iLat, iLon, from real
% lat and lon, but iterate by hand a few times. The largest amount of
% stretching is at the north pole.
%
% % International dateline at equator
iLat = 50;
iLon = 61;
% East of Argentina
% iLat = 20;
% iLon = 95;
%time_series_loc = coordTransform_xyz2fp(iLat, iLon, 1, sim);
time_series_loc = coordTransform_xyz2fp(iLat, iLon, 1, sim);
time_series_lvl = 13;

fprintf("%s.m: Plot time series data for water level #%d of column #%d\n", mfilename, time_series_lvl, time_series_loc)
fprintf("%s.m: Water ", mfilename);
[iLat, iLon, kmt, lat, lon, water_depth_km] = col2latlon(sim, time_series_loc, figNum, "Time Series Water Column...");

return

%% obsolete code that might be educational

% % % ...or use cryptic code to convert water column to lat and lon. reverse is even worse...
% % [iLat, iLon, ~] = ind2sub(size(sim.domain.M3d), sim.domain.wet_loc(time_series_loc));
% % kmt = sim.domain.bottom_lvl(iLat, iLon);   % kmt is level of bottom
% % lat = sim.grd.YT(iLat, iLon,1);
% % lon = mod(180+sim.grd.XT(iLat, iLon,1),360)-180;
% % water_depth_km = sim.grd.ZT3d(iLat, iLon,kmt)/1e+3;
% % fprintf('%s: Water column %d (lat,lon,depth) = (%s N, %s E, %s m)\n', ...
% %     mfilename, time_series_loc, ...
% %     num2str(lat,'%.1f'), ...
% %     num2str(lon,'%.1f'), ...
% %     num2str(sim.grd.zt(time_series_lvl)))
% % time_series_lvl = 10;
% % if time_series_lvl > bgc.kmt(time_series_loc)
% %     error('time series level ("spy") is below ocean bottom!')
% % end

end