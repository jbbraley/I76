data = dat_z{1}(4500:5000,2:13);

fh = figure;

%% Import Spatial data
bound_coord = dlmread('C:\Users\John\Projects_Git\I76\Analysis&Results\Bound_coord.csv',',',1,0);
dof_coord = dlmread('C:\Users\John\Projects_Git\I76\Analysis&Results\Strain_DOF_coord.csv',',',1,0);

% Index channels to be plotted:
gird_chan = [1 2 3 5 7 8];
coord = dof_coord(gird_chan(1:end-1),1:2);
bcoord = bound_coord;
xres = 10;
yres = 10;
sc = 1/4;

z = data(:,gird_chan(1:4));
z(:,end+1) = mean(data(:,gird_chan(5:6)),2);
%% Animate shape and time history

fh = plot_interpmode_animate(coord,bcoord,z*-1,xres,yres,sc);


% %% Time History
% ah = axes;
% 
% % Sampling frequency
% fs = 50;
% dt_s = 1/fs;
% time = 0:dt_s:size(data)*dt_s-dt_s;
% 
% 
% plot(time,data);
% hold all
% ylim = get(ah,'ylim');
% xlim = get(ah,'xlim');
% 
% %Animation frequency (samples per second)
% SpeedX = 1/4;
% fa = fs*SpeedX;
% dt_a = 1/fa;
% %Frame rate (frames per second)
% fr = 10;
% 
% 
% dh = plot([xlim(1) xlim(1)],ylim,'color', 'k');
% for ii = linspace(time(1),time(end), length(time)/(fa/fr))
%     set(dh,'XData',[ii ii]);
%     drawnow
%     pause(1/fr)
% end
