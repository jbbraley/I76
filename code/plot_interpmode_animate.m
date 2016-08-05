function fh = plot_interpmode_animate( coords,bcoords,z,xres,yres,sc)
%% SYNTAX: function plotInterpMode(ah,x,y,z,xres,yres,scale)
%
% jdv 2/15/14; 09222015

    % error screen null bcoords
    if isempty(bcoords)
        % just use coords
        xx = coords(:,1);
        yy = coords(:,2); 
%         zz = z;
    else
        % concat boundaries
        xx = [coords(:,1); bcoords(:,1)];
        yy = [coords(:,2); bcoords(:,2)];
%         zz = [z; bcoords(:,3)];  
    end
    
    
    % interpolate
    xv = linspace(min(xx), max(xx),xres);
    yv = linspace(min(yy), max(yy),yres);
    [xInterp,yInterp] = meshgrid(xv,yv);
    for ii = 1:size(z,1)
        zz = [z(ii,:)'; bcoords(:,3)];
        zInterp(:,:,ii) = griddata(xx,yy,zz,xInterp,yInterp,'v4');
    end
    
    % plot shape to axes
    fh = figure;
    ah = subplot(2,1,2);
%     mesh(ah,xInterp,yInterp,zInterp*sc);
    sh = surf(ah,xInterp,yInterp,zInterp(:,:,1)*sc);
    hold(ah,'on')
    % overlay DOF in red
    dof_h = plot3(ah,coords(:,1),coords(:,2),z(1,:)'*sc,'marker','o',...              
                                          'markerfacecolor','r',...
                                          'markeredgecolor','k',...
                                          'linestyle','none',...
                                          'markersize',6);    
    % overlay boundaries in black
    if ~isempty(bcoords)     % error screen null entry
        plot3(ah,bcoords(:,1),bcoords(:,2),bcoords(:,3),...
            'marker','.','color','k','linestyle','none');
    end
    hold(ah,'off');
    axis(ah,'equal');
    
    % set zlim 
    thresh = 1.2; % extend zlimits by 20% 
    zlim(ah,[-1*max(max(abs(z*sc*thresh))) max(max(abs(z*sc*thresh)))]);
    
    % show normalized modal amplitude on z-axis
    tk = [-1 -.75 -.5 -.25 0 .25 .5 .75 1];
    set(ah,'ztick',max(abs(zz))*abs(sc)*tk,'zticklabel',tk);
    
    % additional formatting
    alpha(.9); % transparency value
    grid(ah,'minor');
    set(ah,'fontname','times new roman','fontsize',16);
    
    %% Plot Time History
    ah2 = subplot(2,1,1);
    plot(z);
    hold all
    ylim = get(ah2,'ylim');
    xlim = get(ah2,'xlim');
    dh = plot([xlim(1) xlim(1)],ylim,'color', 'k');
    
    %% Animate Data
   
    for ii = 1:size(z,1)
        % Shape animation
        set(sh,'ZData',zInterp(:,:,ii)*sc);
        set(dof_h,'ZData',z(ii,:)'*sc)
        % Time History Animation
        set(dh,'XData',[ii ii]);
        drawnow
        pause(1/10)
    end
end
















