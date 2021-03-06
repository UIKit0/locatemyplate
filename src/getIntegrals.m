%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getIntegrals(sample)
%%
%% INPUTS:
%%  - sample, the image sample
%%
%% OUPUTS:
%%  - integrals, the integral images
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function integrals = getIntegrals(sample)
	global INTEGRALS;
	integrals = {};

	integrals{1} = sample;

	% creating the image filters
	Fdx = [-1 0 1;-1 0 1;-1 0 1];
	Fdy = Fdx';

	% Get the abs x-derivative (1st order)
	dx = imfilter(sample, Fdx);
	dxAbs = abs(dx);
	if (~isempty(find(INTEGRALS == 2)))
		integrals{2} = getIntegral(dxAbs);
	end

	% Get the abs y-derivative (1st order)
	dy = imfilter(sample, Fdy);
	dyAbs = abs(dy);
	if (~isempty(find(INTEGRALS == 3)))
		integrals{3} = getIntegral(dyAbs);
	end

	% Get the abs x-derivative (2nd order)
	dx2Abs = abs(imfilter(imfilter(sample, Fdx), Fdx));
	if (~isempty(find(INTEGRALS == 4)))
		integrals{4} = getIntegral(dx2Abs);
	end

	% Get the abs y-derivative (2nd order)
	dy2Abs = abs(imfilter(imfilter(sample, Fdy), Fdy));
	if (~isempty(find(INTEGRALS == 5)))
		integrals{5} = getIntegral(dy2Abs);
	end

	% precalculate means
	Fmean = ones(6)/36;
	dxMean = imfilter(dx, Fmean);
	dyMean = imfilter(dy, Fmean);

	% Calculate abs variance of dx
	if (~isempty(find(INTEGRALS == 6)))
		integrals{6} = abs(dx - dxMean);
	end
	if (~isempty(find(INTEGRALS == 7)))
		integrals{7} = abs(dy - dyMean);
	end

	% Calculate abs variance of abs dx
	if (~isempty(find(INTEGRALS == 8)))
		integrals{8} = abs(dx - abs(dxMean));
	end
	% Calculate abs variance of abs dy
	if (~isempty(find(INTEGRALS == 9)))
		integrals{9} = abs(dy - abs(dyMean));
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getIntegral(sample)
%%
%% INPUTS:
%%  - sample, the image sample
%%
%% OUPUTS:
%%  - integral, the integral image of the sample
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function integral = getIntegral(sample)
	integral = cumsum(cumsum(sample,2));
end
