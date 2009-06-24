%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% data(file)
%%
%% INPUTS:
%%  - file, the index file
%%
%% OUPUTS:
%%  - [I, P, N, D]
%%    * I, the complete images I{i}{j} with j as integral image type
%%    * P, the binary image showing positive samples
%%    * N, the binary image showing negative samples (P = ~N, N = ~P)
%%    * D, the dimensdataidxon [h, w] of a licensplate
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = getData(file)
	text = textread(file, '%s', 'whitespace', '\n\t ');
	M    = size(text, 1);

	I = {}; P = {}; N = {}; D = {};

	dataidx = 1;
	for i = 1:6:M % Assuming 1 license plate per sample
		fprintf('processing data: %0.2f%% complete\n', i/M*100);

		img     = imread(text{i});
		imgGray = double(rgb2gray(img))/256;

		[ySize, xSize] = size(imgGray);

		% Get sample coords
		c = str2num(text{i+1}); % number of license plates
		x = str2num(text{i+2}); % upper left corner x of license plate
		y = str2num(text{i+3}); % upper left corner y of license plate
		w = str2num(text{i+4}); % license plate width
		h = str2num(text{i+5}); % license plate height

		% Fill our fields
		I{dataidx}      = getIntegrals(imgGray);
		P{dataidx}      = zeros(ySize-h+1, xSize-w+1);
		P{dataidx}(y,x) = 1;
		N{dataidx}      = ~P{dataidx};
		D{dataidx}      = [h, w];

		% Increase counter
		dataidx = dataidx + 1;
	end
	data.I = I;
	data.P = P;
	data.N = N;
	data.D = D;
end
