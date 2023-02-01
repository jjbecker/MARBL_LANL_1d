function [T] = fp_ad(domain, nz, av, w)
%
% [T] = ad(Av,nz)
%
% OUTPUTS:
% T: nz x nz advection diffusion transport matrix for a 1-d column
%    model with nz levels
% DEBUG
% keyboard
% [zt_fp,zw_fp,dzt_fp,dzw_fp] = fp_zgrid(nz,H,0.6); 
% zw = zw_fp;       % DEBUG     
% zt = zt_fp;       % DEBUG


%% ====================

% FIXME: need to translate CESM grid to grid Francois generated in old
% days. Generally not too tough but signs are flipped, and his grid 
% explicitly included surface.
%
% FIXME: If you really care about this; note that the Francois dzw(1) and 
% dzw(end) are approximately, but -NOT- exactly, the same as what is here.
%
% zw = -depth edges including 0 and max = size (1,nz+1)
% zt = -depth of cell center            = size (1,nz  )
%
% dzt = (zw(1:end-1)-zw(2:end))'        = size (1,nz  )   = width of cells
% dzw = [0-zt(1) (zt(1:end-1)-zt(2:end)) zt(end)-zw(end)] = size (1,nz+1) = distance between centers

zw = [0 -domain.zw];    % edge, z cordinate, size(1,25) [0 ... -5750]
zt =    -domain.zt;     % center z cordinate,size(1,24) [-29.4 ... -5535.7] 

% distance between edges
dzt = (zw(1:end-1)-zw(2:end  ));    

% distance between centers 
% Note: would need centers off each end to get this perfect...

dzw = [ 0-zt(1)      zt(1:end-1)-zt(2:end)     zt(end)-zw(end) ];

dzw(  1) = dzw(  1)*2;  % size(1,24)    [60.9 .. 428.16]]
dzw(end) = dzw(end)*2;  % size(1,25)    [+57.09 ... 428.67]

%% ====================

    
    % inline function to make a sparse diagonal matrix from vector x
    d0 = @(x) spdiags(x(:),0,length(x(:)),length(x(:)));

    % difference operator
    I = speye(nz+1);
    D = I-I([2:end,1],:); 
    D = D(:,2:end);
    % grad operator (vertical component)
    grad = d0(1./dzw)*D; 
    % div operator (1-d)                                  
    div =  -d0(1./dzt)*D.';  % one-d divergence operator

    % vertical diffusivity
    K = d0(av(zw));    

    % operator for divergence of advective flux
    e = ones(nz,1)/nz;
    c0 = flipud(cumsum(e));
    A = spdiags([c0,-c0],[0,1],nz,nz);
    A(:,1) = A(:,1)-e;
    A = d0(1./dzt)*A;  

    % diffusion flux operator
    F =  -K*grad;
    % enforce the no flux b.c. at the top and bottom
    F(1,:) = 0;
    F(end,:) = 0;
    T = div*F+w*A;
end
