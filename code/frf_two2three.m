function HH = frf_two2three(H,no,ni)
%% [HH,hInd] = frf_two2three(H,no,ni)
%
% convert H [ns x no*ni] (legacy format) -> HH [no x ni x ns] 
%
% jdv 08162015

ns = length(H);
HH = zeros(no,ni,ns);

hInd = 1:no*ni;
hInd = reshape(hInd,no,ni); % index for full solution

for ii = 1:ns           % loop spectral lines
    for jj = 1:no       % loop outputs
        for kk = 1:ni   % loop inputs
            HH(jj,kk,ii) = H(ii,hInd(jj,kk));
        end
    end
end