%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% trainCascader(f, d, Ftarget)
%%
%% INPUTS:
%%  - f, maximum acceptable false positive rate per layer
%%  - d, minimum acceptable detection rate per layer
%%  - Ftarget, overall false positive rate
%%
%% OUPUTS:
%%  - cascader, a cascading classifier
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cascader = trainCascader(f, d, Ftarget)
	cascader = {};

	[I, P, N, D] = getData('train');
	V            = getData('validate');
	features     = featureGeneration(5);

	Fprev = 1; Dprev = 1; i = 0;

	% Create a cascading classifier made out of strong classifiers
	while (Fcur > Ftarget)
		i = i + 1;
		ni = 0;
		Fcur = Fprev;

		% Create the current layer
		while (Fcur > f*Fprev)
			ni = ni + 1;
			[strong, alphas] = vjBoost([I,P,N,D], features, ni);

			layer.classifier = strong;
			layer.alphas     = alphas;
			cascader{i}      = layer;

			% Determine the best threshold for the current layer
			for t = 0.9:-0.1:0.1
				cascader{i}.threshold = t;
				[Fcur, Dcur, N_] = evaluate(cascader, V);
				if (Dcur > d*Dprev)
					break;
				end
			end
		end

		if (Fcur > Ftarget)
			% Implicit empty and replace N
			[Fcur, Dcur, N] = evaluate(cascader, V);
		end

		Dprev = Dcur;
		Fprev = Fcur;
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% evaluate(cascader, validation)
%%
%% INPUTS:
%%  - cascader, the cascading classifier
%%  - validation, the validation set
%%
%% OUPUTS:
%%  - f, the false positive rate
%%  - d, the detection rate
%%  - N, the false positives
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f, d, N] = evaluate(cascader, validation)
	I = validation(1); % True images
	P = validation(2); % Binary images for positive samples
	N = validation(3); % Binary images for negative samples
	D = validation(4); % Dimension of license plate per image

	fP = 0; tP = 0; fN = 0; tN = 0;
	for i = 1:length(I)
		Ci = classify(cascader, I{i}, D{i});
		Pi = P{i};
		Ni = N{i};

		TP =  Ci & Pi; % tp =  C and P
		FP =  Ci & Ni; % fp =  C and N
		TN = ~Ci & Ni; % tn = !C and N
		FN = ~Ci & Pi; % fn = !C and P

		fP = fP + sum(sum(FP));
		tP = tP + sum(sum(TP));
		fN = fN + sum(sum(FN));
		tN = tN + sum(sum(TN));

		% Set the new negative set to the false positives
		N{i} = FP;
	end
	f = fP / (fP + tP);
	d = tP / (fP + tP);
end