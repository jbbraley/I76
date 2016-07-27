function varargout = cmif_plot(ah,f,ss,bnds,peakLoc,rank)
%% function 
% ah = cmif_plot = cmif_plot...
%
% inputs:
%   bnds    frequency bounds (optional)
%
%
% examples:
%
%   simple plot:
%   ah = cmif_plot(ah,f,ss,bnds,0,0)
%
%   plot peaks:
%   ah = cmif_plot(ah,f,ss,bnds,peakLoc,rank)
%
%   pick peaks:
%   [ah, peakLoc, rank] = cmif_plot(ah,f,ss,bnds,[],[])
%
%   
% jdv 09022015; 07162016

    % plot CMIF 
    plot(ah,f,mag2db(ss),'.-')
    if ~isempty(bnds)  
        % error screen null bnds entry
        xlim(ah,bnds);
    end

    % return axes handle
    varargout{1} = ah;
    
    % optional format
    cmif_format(ah);

    % check for peak selection
    if isempty(peakLoc) || isempty(rank)
        % manual peak selection
        [peakLoc,rank] = cmif_pick(ss,f);        
        % save peak location indices and rank
        varargout{2} = peakLoc;
        varargout{3} = rank;
    end
    
    % if zero, don't plot
    if peakLoc(1) ~= 0 || rank(1) ~= 0
        % add global poles to plot
        cmif_addpeaks(ah,f,ss,peakLoc,rank);   
    end 

end

% optional format
function cmif_format(ah)
    % format cmif plot
    
    % axes
    grid(ah,'on'); 
    grid(ah,'minor');
    xlabel(ah,'Frequency [Hz]');
    ylabel(ah,'Singular Value Magnitude [db]');
    set(ah,'fontname','times new roman','fontsize',18);
    
    % lines
    lh = findobj(ah.Children,'type','line');
    set(lh,'linewidth',1,'markersize',14);
end


function [peakLoc,rank] = cmif_pick(ss,f)
%% function ind = cmif_pick(ss)
% jdv 09022015
    nn = 1;  % counter index
    chk = 1; % selection logic 
    while chk == 1
        % get user input
        [xx,yy,btn] = ginput(1);
        % find nearest frequency
        [~,pk] = searchVector(f,xx);
        % find rank
        [~,rnk] = min(abs(mag2db(ss(pk,:)) - yy));    
        % save values
        peakLoc(nn) = pk;
        rank(nn) = rnk;    
        % advance counter
        nn = nn+1;    
        % store logic
        chk = btn;
    end
end

function cmif_addpeaks(ah,f,ss,peakLoc,rank)
%% add peaks to cmif plot
%
% jdv -9022015;
% jdv 12212015 - add text overlay for peak index
    hold(ah,'all');
    ne = length(peakLoc);
    % loop singular values
    for ii = 1:ne 
        % get line handle
        lh(ii) = plot(ah,f(peakLoc(ii)),mag2db(ss(peakLoc(ii),rank(ii))),'ro');
        % define text offset
        dx = .025; dy = 1.25; % default text offset
        % create text
        th = text(f(peakLoc(ii))+ dx,mag2db(ss(peakLoc(ii),rank(ii)))+dy,...
            num2str(ii),'fontsize',11);
        
    end    
    % format line
    set(lh,'color','r',...
           'linewidth',2);
    hold(ah,'off');
end


