% Distance between bottom gauge and web gauge
d1 = 12+1.375;
% Calculate strain at top of deck
d2 = 1.375+68+.625+8; % Distance to top o fdeck from bottom of flange
Str_D = (dat1(:,4)-dat1(:,2))*d2/d1+dat1(:,2);

figure
plot(Str_D)
hold all
plot(dat1(:,2))
plot(dat1(:,4))
legend({'Top of Deck', 'Bottom Flange', 'Web'});

% Plot neutral axis
NA_loc = -dat1(:,2)*d1./(dat1(:,4)-dat1(:,2));
figure
plot(NA_loc)

%Filter
%Apply lowpass filter
fs = 50;
[b,a] = ellip(4,.5, 40, 1.5/(fs/2),'low');
na_filt = filter(b,a,NA_loc);
ylim([-10 60]);

%Compare measured and extrapolated high web responses
d3 = 22.33+1.375;
d4 = d3 + 22.33;

w2_str_est = (dat1(:,9)-mean(dat1(:,7:8),2))*d4/d3+mean(dat1(:,7:8),2);

w2_diff = w2_str_est - dat1(:,10);