function [uu,ss,vv] = cmif_svd(hh)
%% function [uu,ss,vv] = cmif_svd(hh)
% hh - frf matrix size [no x ni x ns]
% jdv 08162015

    % svd
    uu = []; vv = []; ss = [];
    ns = size(hh,3);                    % setup
    for ii = 1:ns                       % loop spectral lines
        [ut,st,vt] = svd(hh(:,:,ii));   % svd for shapes
        uu(:,:,ii) = ut;                % row vector
        vv(:,:,ii) = vt;                % column vector
        ss(ii,:) = diag(st);            % diagonal for singular values
    end

end
