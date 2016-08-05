
addpath(genpath('C:\Users\John\Projects_Git\vma'));
fname_base = 'TOA5_20Hz_strain_data_';
base_char = length(fname_base);
fdir = 'C:\Users\John\Documents\RutgersResearch\Virtual Lab\I76\data\Full\strain\Converted';
fnames = dir(fdir);

dat = [];
n=1;
for ii = 3:size(fnames,1)
    if length(fnames(ii).name)>base_char && strcmp(fnames(ii).name(1:base_char),fname_base)
        try
            dat{n} = dlmread([fdir '\' fnames(ii).name],',',4,1);
        catch
            continue
        end
%         Big(n,:) = max(dat,[],1)-mean(dat,1);
%         Smal(n,:) = min(dat,[],1)-mean(dat,1);
        order(n) = str2double(fnames(ii).name(base_char+1:end-4));
        n=n+1;
    end
end

order(end+1:end+4) = [3 7 13 14];

dat{end+1} = dlmread([fdir '\' fname_base '3.dat'],',',88,1);
dat{end+1} = dlmread([fdir '\' fname_base '7.dat'],',',5,1);
dat{end+1} = dlmread([fdir '\' fname_base '13.dat'],',',69,1);
dat{end+1} = dlmread([fdir '\' fname_base '14.dat'],',',5,1);

%% Sort data
[~, rec_ind] = sort(order);

dat = dat(rec_ind);

% Zero Data
for ii = 1:length(dat)
    for jj=1:size(dat{ii},2)
        dat_z{ii}(:,jj) = dat{ii}(:,jj)-mean(dat{ii}(:,jj));
    end
end

%% Plot data
% set labels
dof.labels = {'BF MID G1' ...
              'BF MID G4' ...
              'BF MID G5' ...
              'WEB MID G4' ...
              'BF 3/4 G4' ...
              'WEB XG' ...
              'RIGHT BF'...
              'LEFT BF' ...
              'WEB LOWER' ...
              'WEB UPPER'...
              'XG MID TOP' ...
              'XG MID BOT'};

ah = axis;
strain_chan = 2:13;
for ii = 1:length(dat)
    plot(dat_z{ii}(:,strain_chan))
    title(['Record_' num2str(ii)])
    legend(dof.labels,'location','northwest')
    ylim([-100 180])
    pause
end