%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vjBoost(data, features, T)
%%
%% INPUTS:
%%  - data, data.x{i} the image, data.y(i) in {0, 1} pos or neg sample
%%  - features, the list of generated features
%%  - T, number of best features
%%
%% OUPUTS:
%%  - I, the T best weak features indexes
%%  - alpha, their corresponding weights
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I, alpha] = vBoost(data, features, T)
	% Discriminate positive and negative samples
	pos = (data.y == 1);
	neg = (data.y == 0);

	% Initialize some vars
	I     = zeros(1, T);
	alpha = zeros(1, T);
	W     = ones(1, size(data,2));
	E     = ones(1, size(data,2));
	Ep    = ones(1, size(data,2));
	H     = size(features, 2);

    % Initialize the sample weights distribution
    m      = size(neg(neg == 1), 2);
    l      = size(pos(pos == 1), 2);
	W(neg) = W(neg) ./ (2*m);
	W(pos) = W(pos) ./ (2*l);

	for t = 1:T
		% Normalize the weights
		W = W ./ sum(W);

		% Select the best feature
		Et = inf; Ht = 1;
		for h = 1:H
			s = 0;
			trainWeakClassifier(features{h}, data, m, l);
			for i = 1:l+m
				Ep(i) = weakClassify(features{h}, data.x{i}, data.imgInt{i});
				s     = s + W(i) * abs( Ep(i) - data.y(i) );
			end
			if (s < Et)
				Et = s;
				Ht = h;
				E  = Ep;
			end
		end

		% Store the best feature at place t
		I(t) = Ht;

		% Update the weights
		beta = Et / ( 1 - Et );
		W = W .* ( beta .^ E );

		% Calculate alpha weight
		alpha(t) = log(1./beta);
	end
end