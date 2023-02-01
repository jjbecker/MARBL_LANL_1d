function [surface, interior] = update_forcing ( t, surface, interior)

% Calculate forcing at current time of surface and interior.
%
% input args are current time in second, current surface and
% interior state.
%
% FIXME: Surface is not updated for now. 
% 
% Note: In MARBL -surface- sunlight (PAR) is -interior- forcing...

const.sec_h = 60 * 60;
const.sec_d = const.sec_h * 24;

% time is measured in seconds.

tod = mod (t, const.sec_d);
% d   = floor(t/const.sec_d);
% hr  = floor(tod/const.sec_h);
% min = floor(mod(tod/60, 60));
% s   = floor(mod(tod, 60));

sunrise =  6 * const.sec_h;
sundown = 18 * const.sec_h;

if (t == 0)
    disp(['Sunrise (hr) ', num2str(sunrise/const.sec_h)])
    disp(['Sundown (hr) ', num2str(sundown/const.sec_h)])
end


% MARBL attenuates with depth.
% PAR is surface 400-700(nm) -AIR-
% Surface Shortwave (W/m^2)

if (tod >sunrise && tod <sundown) 
    tmp = 450 * sin(pi*(tod-sunrise)/(sundown-sunrise))^2; 
else
    tmp = 0; 
end
interior.forcing(2,:) = tmp;

end

