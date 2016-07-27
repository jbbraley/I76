
%% setup 

% file name to publish
fname = 'I76_Ambient_Processing.m';

% set format spec for doc
opts.format = 'html'; % default
% opts.createThumbnail = true;

% % set relative size of images
% opts.maxHeight = 640;
% opts.maxWidth = 480;

% publish
pubName = publish(fname,opts);


%% post-processing

fname = 'I76_Ambient_PostProcessing.m';
opts.format = 'html'; 
pubName = publish(fname,opts);