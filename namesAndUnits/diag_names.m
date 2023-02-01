function [name] = diag_names(diag_name, diag_cnt)

% Call MARBL to get the many many diags name, which is needed because of
% CISO changes dimenstions of tracers and most other things.
%
% "diag_cnt" was returned by init_marbl() call and saved for future use 
% 
%     interior.diag_name     = diag_names   ( 'interior_tendency_diags', interior.diag_cnt );
%     surface. diag_name     = diag_names   ( 'surface_flux_diags'     , surface. diag_cnt );
% 
% this -does- work after "shutdown" but -not- before "init"

name = cell(diag_cnt,1);

for i = 1:diag_cnt
    name{i} = mex_marbl_driver('diag_sname', diag_name, i);
end

end
