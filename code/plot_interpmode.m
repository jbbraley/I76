function plot_interpmode(ah,coords,bcoords,z,xres,yres,sc)
%% SYNTAX: function plotInterpMode(ah,x,y,z,xres,yres,scale)
%
% jdv 2/15/14; 09222015

    % error screen null bcoords
    if isempty(bcoords)
        % just use coords
        xx = coords(:,1);
        yy = coords(:,2); 
        zz = z;
    else
        % concat boundaries
        xx = [coords(:,1); bcoords(:,1)];
        yy = [coords(:,2); bcoords(:,2)];
        zz = [z; bcoords(:,3)];  
    end
    
    % interpolate
    xv = linspace(min(xx), max(xx),xres);
    yv = linspace(min(yy), max(yy),yres);
    [xInterp,yInterp] = meshgrid(xv,yv);
    zInterp = griddata(xx,yy,zz,xInterp,yInterp,'v4');
    
    % plot shape to axes
%     mesh(ah,xInterp,yInterp,zInterp*sc);
    surf(ah,xInterp,yInterp,zInterp*sc);
    hold(ah,'on')
    % overlay DOF in red
    plot3(ah,coords(:,1),coords(:,2),z*sc,'marker','o',...              
                                          'markerfacecolor','r',...
                                          'markeredgecolor','k',...
                                          'linestyle','none',...
                                          'markersize',6)    
    % overlay boundaries in black
    if ~isempty(bcoords)     % error screen null entry
        sh = plot3(ah,bcoords(:,1),bcoords(:,2),bcoords(:,3),...
            'marker','.','color','k','linestyle','none');
    end
    hold(ah,'off');
    axis(ah,'equal');
    
    % set zlim 
    thresh = 1.2; % extend zlimits by 20% 
    zlim(ah,[-1*max(abs(z*sc*thresh)) max(abs(z*sc*thresh))]);
    
    % show normalized modal amplitude on z-axis
    tk = [-1 -.75 -.5 -.25 0 .25 .5 .75 1];
    set(ah,'ztick',max(abs(zz))*abs(sc)*tk,'zticklabel',tk);
    
    % additional formatting
    alpha(.9); % transparency value
    grid(ah,'minor');
    set(ah,'fontname','times new roman','fontsize',16);
end
















