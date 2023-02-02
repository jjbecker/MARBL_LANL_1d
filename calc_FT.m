%%
% Francois has a simple 1d advection example. It's not realistic, but it
% provides some mixing to keep tracers from blowing on on very long runs...

function [FT] = calc_FT(interior, dt)

% direction of water flow is -UP- towards surface, +z, aka "LESS deep"
%   w>0. sign of w is very confusing, see below :-)

% vertical advection
a = 6371e3; % Earth radius
area = 0.71*4*pi*a^2; % surface area of ocean
f = 20e6; % (m^3/s) deep water formation rate
w = f/area; % (m/s)
% FIXME: need bigger upwelling or trapizoid integration of tendency crashes.
w = w*100;
fprintf('%s.m: upwelling = %.3g (m/s)\n', mfilename, w)

% T = transport (interior.domain, w);
% vertical diffusivity
% enhanced diffusivity in mixed layer

mixed_layer_thickness = 100.;    % meters
fprintf('%s.m: mixed_layer_thickness = %g (m)\n', mfilename, mixed_layer_thickness)
av = @(z) (z>-mixed_layer_thickness).*(0.1)+4e-4;

T = fp_ad(interior.domain, size(interior.domain.zw,2), av, w);

FT = mfactor( speye(size(interior.domain.zw,2)) +dt*T);

end