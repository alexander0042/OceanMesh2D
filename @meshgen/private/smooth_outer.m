function efs = smooth_outer(efs,Fb)
% This method takes a cell-aray of edge function class instances
% and smoothes them together so they blend into each other.
% Relax gradient of outer edgefx with inner edgefx using limgradStruct
for ii = length(efs)-1:-1:1
    hh_m = efs{ii}.F.Values; found = 0;
    for bn = ii+1:length(efs)
        % smooth with all inner boxes (with buffer)
        x = efs{ii}.F.GridVectors{1}; dx = x(2) - x(1);
        inx = x >= min(efs{bn}.F.GridVectors{1}) - 1*dx & ...
            x <= max(efs{bn}.F.GridVectors{1}) + 1*dx;
        y = efs{ii}.F.GridVectors{2}; dy = y(2) - y(1);
        iny = y >= min(efs{bn}.F.GridVectors{2}) - 1*dy & ...
            y <= max(efs{bn}.F.GridVectors{2}) + 1*dy;
        if isempty(find(inx,1)) || isempty(find(iny,1)); continue; end
        found(bn) = 1;
        % Get the grid of coarse one inside the fine one
        [x,y] = ndgrid(x(inx),y(iny));
        % Use fine griddedInterpolant to interpolate fine to coarse
        hh_t = efs{bn}.F(x,y);
        % mask non-square component
        nonsq = inpoly([x(:),y(:)],efs{bn}.boubox(1:end-1,:)) ;
        h_old = hh_m ; % copy it
        hh_t(~nonsq)=NaN; % mask it
        hh_m(inx,iny) = hh_t; % put all of it in (w/ NaN)
        hh_m(isnan(hh_m))=h_old(isnan(hh_m)); % replace NaN with old
    end
    if all(found == 0); continue; end
    disp(['Relaxing the gradient of #' num2str(ii) ' outer edgefx ' ...
        'using #' num2str(find(found)) ' inner edgefxs']);
    hfun = reshape(hh_m',[numel(hh_m),1]);
    [xg,yg] = ndgrid(efs{ii}.F.GridVectors{1},efs{ii}.F.GridVectors{2});
    % kjr  Oct 2018 consistent with default application of gradient limiting!
    dx = efs{ii}.h0*cosd(yg(1,:));
    dy = efs{ii}.h0;
    
    % make g a function of space
    dmy     = xg*0 ;
    for param = efs{ii}.g'
        if numel(param)==1 && param~=0
            lim   = efs{ii}.g;
            dmy  = dmy + lim ;
        else
            lim  = param(1);
            dp1 = param(2);
            dp2 = param(3);
            
            limidx = (Fb{ii}(xg,yg) < dp1 & ...
                Fb{ii}(xg,yg) > dp2) ;
            
            dmy( limidx ) = lim;
        end
    end
    fdfdx = reshape(dmy',[numel(dmy),1]);
    clearvars dmy limidx xg yg;
    
    [hfun,flag] = limgradStruct(efs{ii}.ny,dx,dy,hfun,...
        fdfdx,sqrt(length(hfun)));
    
    if flag == 1
        disp('Gradient relaxing converged!');
    else
        error(['FATAL: Gradient relaxing did not converge, '
            'please check your edge functions']);
    end
    % reshape it back
    hh_m = reshape(hfun,efs{ii}.ny,[])';
    clearvars hfun fdfdx
    % Save it back into the interpolant
    efs{ii}.F.Values = hh_m;
end
end

