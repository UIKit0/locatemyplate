%%%%% GLOBAL CONSTANTS %%%%%
global INTEGRALS SEGMENTS DEBUG SCALEFACTOR train validate features;

% Number of integral images
INTEGRALS   = 5;

% Number of segments/blocks within a feature
SEGMENTS    = 2;

% Maximal number of negative samples per image for weaktrainer
MAXSAMPLES  = 100;

% Show debug information
DEBUG       = false;

% Scaling factor on train and validate data
SCALEFACTOR = 0.5;

% Load train data
trainfile = sprintf('../cache/train-%0.1f.mat', SCALEFACTOR); 
if (exist(trainfile))
	fprintf('\nloading %s from cache\n\n', trainfile);
	load(trainfile);
else
	fprintf('\ngenerating and saving %s\n\n', trainfile);
	train = getData('../data/stills/plates-train.idx', SCALEFACTOR);
	save(trainfile, 'train');
end

% Load validate data
validatefile = sprintf('../cache/validate-%0.1f.mat', SCALEFACTOR); 
if (exist(validatefile))
	fprintf('\nloading %s from cache\n\n', validatefile);
	load(validatefile);
else
	fprintf('\ngenerating and saving %s\n\n', validatefile);
	validate = getData('../data/stills/plates-validate.idx', SCALEFACTOR);
	save(validatefile, 'validate');
end

% Load feature data
featurefile = sprintf('../cache/feature-%d.mat', SEGMENTS);
if (exist(featurefile))
	fprintf('\nloading %s from cache\n\n', featurefile);
	load(featurefile);
else
	fprintf('\ngenerating and saving %s\n\n', featurefile);
	features = featureGeneration(SEGMENTS);
	save(featurefile, 'features');
end
