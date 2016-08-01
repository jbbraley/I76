%% Look for change in transverse acceleration
% Find record corresponding to 2:01
% find all files with correct filenames
addpath(genpath('C:\Users\John\Projects_Git\vma'));
fname_base = 'I76_07282015_ambient_AM1';
base_char = length(fname_base);
fdir = 'F:\I76\07282016_Data';
fnames = dir(fdir);

dat = [];
n=1;
for ii = 1:size(fnames,1)
    if length(fnames(ii).name)>base_char && strcmp(fnames(ii).name(1:base_char),fname_base)
        dat{n} = dlmread([fdir '\' fnames(ii).name],'\t');
        order(n) = str2double(fnames(ii).name(end-5:end-4));
        n=n+1;
    end
end

order(isnan(order))=0;

data = [];
for ii=0:max(order)
    data = cat(1,data,dat{find(order==ii)});
end

figure
plot(data(:,19))

endind = 6.096e+05;
beginind = 6.449e+05;

RMS1 = getrms(data(1:endind,19));
RMS2 = getrms(data(beginind:end,19));

fs = 200;
block_size = fs*60*10;
for jj=1:floor(size(data,1)/block_size)
    RMS_AM2(jj) = getrms(data((jj-1)*block_size+1:jj*block_size,6));
end
%% Check for high records
