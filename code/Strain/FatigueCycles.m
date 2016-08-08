%% Data rainflow counting

data = dat_z{3}(:,3);
tp = sig2ext(data);
rf = rainflow(tp);
figure
rfhist(rf,20,'ampl');
[no, xo] = rfhist(rf,20,'ampl');