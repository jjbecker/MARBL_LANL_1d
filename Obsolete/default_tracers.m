function [surface, interior] = default_tracers ( surface, interior, lciso_on )

% THere are a lot of initial conditions needed for every single level of
% every single water column: at least 32 tracers, 46 if carbon isotopes
% aka "CISO" is turned on. Even a minimal simulation of a single water
% column with 5 levels has at lest 160 initial conditions required.
%
% Furthermore, MARBL is not "tolerant" of inconsistent values. For example
% if the dust flux an Fe values are not realistic, MARBL crashes.
%
% If carbonate and pH values are inconsistent, MARBL does NOT usually crash
% but the results will be wrong. This is hard to detect. Its best to use a
% know good set of carbonate values and slowly change these in sort simple
% simulations till you get something that is obviously CORRECT..
%
% I couldn't find a test case from NARBL developers that I could use as a
% starting point. And it has been extremely tedious to find a consistent
% set of initial conditions for all 32 or 46 tracers. But after a great
% deal of trial and error, the following values are consisten with the
% values in intial forcing "default_forcing.m" and initial pH or
% "default_states.m".
%
% Becasue these intital conditions in the 3 "default_XXX.m" routines are
% consistent, it is possible to run the simulation with a reasonable time
% step, say 15 simualted minutes, for a few simulated years, and the final
% values are somewaht realistic, in particular as a realistic intial
% condition.
%
% Saving the results is better, "spun up", initial condition.
%
% Note: surface and interior have "level" and tracer indices swapped...

% transfer from MARBL correct sized array of garbge, zero that...

interior.tracer = mex_marbl_driver('tracers');


% hack in some initial values for this required tracers. Simulation will
% likely crash if these are initialized to something close to realsitic
% values.

% FIXME: set interior to surface values, then touch up a few

interior.tracer (:,:) = 1e-15;   % avoid divide by zero,
interior.tracer(mex_marbl_driver('tracer_index','PO4'), :) =   2.11; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','NO3'), :) =   10.0; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','SiO3'),:) =   0.33; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','NH4'), :) =   0.28; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','Fe') , :) = 11.e-5; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','Lig'), :) = 1.1e-3; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','O2') , :) =    204; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DIC'), :) =   1980; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','ALK'), :) =   2344; % (meq /m^3)
interior.tracer(mex_marbl_driver('tracer_index','DOC'), :) =   10.0; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DON'), :) =    0.9; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DOP'), :) =   0.11; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DOPr'),:) =   0.01; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DONr'),:) =    0.2; % (mmol/m^3)
interior.tracer(mex_marbl_driver('tracer_index','DOCr'),:) =    2.4; % (mmol/m^3)

% The following "biota" tracers can be left at zero and will not crash the
% simulation.

% intitalize zoo and autotrophs at noticible amount
interior.tracer(mex_marbl_driver('tracer_index','zooC'),:)  = 0.25;
interior.tracer(mex_marbl_driver('tracer_index','spC'),:)   = 0.30;
interior.tracer(mex_marbl_driver('tracer_index','diatC'),:) = 0.04;
interior.tracer(mex_marbl_driver('tracer_index','diazC'),:) = 0.04;

% The autrophs only require above "Carbon" or "xxxC" tracers to be set,
% but there might be a big startup transient if you do not set reasonable
% inital values for the chlorophl, P, Fe, CaCO3 and Si as appropriate.
% These are approximated with very ad hoc fractions of the carbon.

% small phyto at noticible amount
interior.tracer(mex_marbl_driver('tracer_index','spChl'),:)   =  0.2 * interior.tracer(mex_marbl_driver('tracer_index','spC'),:); % Chl
interior.tracer(mex_marbl_driver('tracer_index','spP'),:)     = 0.01 * interior.tracer(mex_marbl_driver('tracer_index','spC'),:); % P
interior.tracer(mex_marbl_driver('tracer_index','spFe'),:)    = 1e-5 * interior.tracer(mex_marbl_driver('tracer_index','spC'),:); % Fe
interior.tracer(mex_marbl_driver('tracer_index','spCaCO3'),:) = 1e-5 * interior.tracer(mex_marbl_driver('tracer_index','spC'),:); % CaCO3

% small diatom at noticible amount
interior.tracer(mex_marbl_driver('tracer_index','diatChl'),:) = 2e-1 * interior.tracer(mex_marbl_driver('tracer_index','diatC'),:); % Chl
interior.tracer(mex_marbl_driver('tracer_index','diatP'),:)   = 1e-2 * interior.tracer(mex_marbl_driver('tracer_index','diatC'),:); % P
interior.tracer(mex_marbl_driver('tracer_index','diatFe'),:)  = 1e-5 * interior.tracer(mex_marbl_driver('tracer_index','diatC'),:); % Fe
interior.tracer(mex_marbl_driver('tracer_index','diatSi'),:)  = 4e-2 * interior.tracer(mex_marbl_driver('tracer_index','diatC'),:); % Si
% diazotroph at noticible amount
interior.tracer(mex_marbl_driver('tracer_index','diazChl'),:) = 1e-1 * interior.tracer(mex_marbl_driver('tracer_index','diazC'),:); % Chl
interior.tracer(mex_marbl_driver('tracer_index','diazP'),:)   = 1e-2 * interior.tracer(mex_marbl_driver('tracer_index','diazC'),:); % P
interior.tracer(mex_marbl_driver('tracer_index','diazFe'),:)  = 1e-4 * interior.tracer(mex_marbl_driver('tracer_index','diazC'),:); % Fe

if lciso_on == 1
    
    % If ~1% of C is 13C, and 99% is 12C, then
    % I would expect DI13C to be 1% of DIC, and so on.
    %
    % not sure what DI13C -really- is, but it appears to be source of
    % DO13C in sp, zoo, diaz, and diatoms. Values appears to be stable at
    % DI12C + 2*forcing+ air-sea fractionation.
    % FIXME: I wonder why?
    interior.tracer(mex_marbl_driver('tracer_index','DI13C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','DIC'),:) ...
        +15 + 2*surface.forcing(1,12); % d13c (permil)
    
    interior.tracer(mex_marbl_driver('tracer_index','DI14C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','DIC'),:) ...
        +32 + 2*surface.forcing(1,13); % d14c (permil)
    
    % Initialize stable and radio isotopes to DOC, and for biota type.
    
    interior.tracer(mex_marbl_driver('tracer_index','DO13Ctot'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','DOC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','DO14Ctot'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','DOC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','zootot13C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','zooC'),:);
    interior.tracer(mex_marbl_driver('tracer_index','zootot14C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','zooC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','sp13C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','spC'),:);
    interior.tracer(mex_marbl_driver('tracer_index','sp14C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','spC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','diat13C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','diatC'),:);
    interior.tracer(mex_marbl_driver('tracer_index','diat14C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','diatC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','diaz13C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','diazC'),:);
    interior.tracer(mex_marbl_driver('tracer_index','diaz14C'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','diazC'),:);
    
    interior.tracer(mex_marbl_driver('tracer_index','spCa13CO3'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','spCaCO3'),:);
    interior.tracer(mex_marbl_driver('tracer_index','spCa14CO3'),:) = ...
        interior.tracer(mex_marbl_driver('tracer_index','spCaCO3'),:);
    
    
%     interior.tracer(mex_marbl_driver('tracer_index','DI13C'),:)     = 1541;
%     interior.tracer(mex_marbl_driver('tracer_index','DO13Ctot'),:)  =   10;
%     interior.tracer(mex_marbl_driver('tracer_index','DI14C'),:)     = 1683;
%     interior.tracer(mex_marbl_driver('tracer_index','DO14Ctot'),:)  =   11;
%     
%     interior.tracer(mex_marbl_driver('tracer_index','zootot13C'),:) = 0.1958;
%     interior.tracer(mex_marbl_driver('tracer_index','zootot14C'),:) = 0.2092;
%     
%     interior.tracer(mex_marbl_driver('tracer_index','sp13C'),:)     = 0.2085;
%     interior.tracer(mex_marbl_driver('tracer_index','sp14C'),:)     = 0.2230;
%     interior.tracer(mex_marbl_driver('tracer_index','spCa13CO3'),:) = 0.0092;
%     interior.tracer(mex_marbl_driver('tracer_index','spCa14CO3'),:) = 0.0100;
%     
%     interior.tracer(mex_marbl_driver('tracer_index','diat13C'),:)   = 0.0385;
%     interior.tracer(mex_marbl_driver('tracer_index','diat14C'),:)   = 0.0410;
%     
%     interior.tracer(mex_marbl_driver('tracer_index','diaz13C'),:)   = 0.0308;
%     interior.tracer(mex_marbl_driver('tracer_index','diaz14C'),:)   = 0.0327;
%     
    
end


% FIXME: pH 8.2, DIC 2002, ALK 2311, psu = 34.78
%
% idx = 2:size(interior.tracer,2);
%
% interior.tracer ( mex_marbl_driver('tracer_index','O2') , idx) =  204.; % (mmol/m^3)
% interior.tracer ( mex_marbl_driver('tracer_index','DIC'), idx) = 2002.; % (mmol/m^3)
% interior.tracer ( mex_marbl_driver('tracer_index','ALK'), idx) = 2311.; % (meq /m^3)

interior.tracer ( mex_marbl_driver('tracer_index','DIC_ALT_CO2'), :) = interior.tracer(mex_marbl_driver('tracer_index','DIC'),:);
interior.tracer ( mex_marbl_driver('tracer_index','ALK_ALT_CO2'), :) = interior.tracer(mex_marbl_driver('tracer_index','ALK'),:);


% Set the size of surface here, for use elsewhere

surface.tracer (1,:) = interior.tracer(:,1)';

end % init_tracers.m
