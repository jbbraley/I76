% Apply bandstop filter   
figure
[b,a] = butter(5, [1.5 24]/(fs/2), 'stop');
freqz(b,a,32000,fs)

y2 = filter(b,a,dat1);
figure
plot(y2(600:1000,3))
hold all
plot(dat1(600:1000,3))

%Apply lowpass filter
fs = 50;
[b,a] = ellip(4,.5, 40, 1.5/(fs/2),'low');
freqz(b,a,32000,fs)

y3 = filter(b,a,dat1);
figure
plot(y3(:,3))
hold all
plot(dat1(:,3))

figure
plot(dat1(:,