function [an_array] = zero_NAN(an_array)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% sadly this doesnt work on structs
% for m = 1:nargin
%     disp(['Calling variable ' num2str(m) ' is ''' inputname(m) '''.'])
% end
% 
% s = inputname(1);
%s 
if sum(~isfinite(an_array),'all')
%     fprintf('%s:m found %d elements %s. Zeroing them...\n', mfilename, sum(~isfinite(an_array),'all'))
    fprintf('%s:m found %d NaN. Zeroing them...\n', mfilename, sum(~isfinite(an_array),'all'))
    an_array(isnan(an_array)) = 0;
end

end