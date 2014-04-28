function saxelab_RFX_old(varargin)
% Updated random-effects analysis script. This script will extend the
% functionality of saxelab_RFX_bch_spm8 by adding two sample t-tests, such
% that two groups can be compared. Also added is the ability to construct
% across-subject regressors (i.e., age) as a covariate of interest. 
% 
% The script requires several bits of information, which can be provided
% optionally when the function is called, otherwise the information will be
% acquired via a series of prompts. The full specification is:
%	saxelab_RFX(type,{'study'},'task',imagefile,{'subjects'})
%		where: 
%			:: type : an INTEGER indicating what type of RFX analysis that 
%			will be performed. 
%				1 : one-sample T-test (for one group)
%				2 : two-sample T-test (for comparing two groups)
%				3 : one-sample T-test with covariate
%				4 : two-sample T-test with covariate *** this has yet to be
%						implemented!
%			:: study : a STRING indicating which study the RFX analysis
%			will be performed on. Alternatively, study may be a CELL ARRAY
%			that contains multiple studies. 
%			:: task : a STRING indicating the name of the task folder that
%			contains the images of interest. Alternatively, task may be a
%			CELL ARRAY that contains multiple tasks.
%			:: subjects : a CELL ARRAY of STRINGS specifying the subjects
%			on which the analysis is to be performed. 
%			:: imagefile : a STRING or an INTEGER specifying the images to 
%			be used for the analysis. If a STRING, it must specify the name 
%			of the contrast, in whole or in part. If an INTEGER, the script
%			will select that contrast file from each and every subject. 
%
%
%% ===================== Parse Input Arguments ============================

if numel(varargin) == 1 & ischar(varargin{1})
	load(varargin{1});
else
cd /mindhive/saxelab2
if numel(varargin) < 1
	type = listdlg('ListSize',[300 100],'SelectionMode','single','PromptString','Select analysis type','ListString',{'Single-Group RFX Analysis','Two-Group RFX Analysis','Single-Group RFX Analysis with Covariate','Two-Group RFX Analysis with Covariate'});
	%type = listdlg('ListSize',[300 75],'SelectionMode','single','PromptString','Select analysis type','ListString',{'Single-Group RFX Analysis','Two-Group RFX Analysis','Single-Group RFX Analysis with Covariate'});
else
	type = varargin{1};
end

if numel(varargin) < 2
	studiesT = dir('*');
	studies = {studiesT([studiesT.isdir]).name};
	study = {studies{listdlg('ListSize',[300 600],'SelectionMode','multiple','PromptString','Select studies for analysis','ListString',studies)}};
elseif ~iscell(varargin{2})
	study = {varargin{2}};
else
	study = varargin{2};
end

if numel(varargin) < 3
	% iterate through the studies and find tasks.
	temp = {};
	for i=1:length(study)
		[a tempT] = system(sprintf('ls /mindhive/saxelab2/%s/*/results/* -dpm',study{i}));
		tempT = regexp(tempT,',','split');
		temp = {temp{:} tempT{:}};
	end
	% iterate over task directories and pull out just the task name
	newtemp = {};
	for i=1:length(temp)
		if temp{i}(end) == '/'
			theTask = regexp(temp{i},'/','split');
			theTask = theTask{end-1};
			newtemp{end+1} = theTask;
		end
	end
	temp = unique(newtemp);
	task = {temp{listdlg('ListSize',[300 600],'SelectionMode','multiple','PromptString','Select tasks for analysis','ListString',temp)}};
elseif ~iscell(varargin{3})
    task = {varargin{3}};
else
    task = varargin{3};
end

% con_type indicates the means of contrast image specification. If it is 1,
% then the user specified the contrast using a numeral. If it is 2, then
% the user specified the contrast using a string. 
con_type = 0;
if numel(varargin) < 4
	contrast = inputdlg('Contrast of interest (name or number)');
	if any(str2num(contrast{:}))
		contrast = str2num(contrast{:});
		con_type = 1;
	else
		con_type = 2;
    end
else
    contrast = varargin{4};
    if ~ischar(contrast)
		con_type = 1;
	else
		con_type = 2;
    end
end
if numel(varargin) < 5
	% find subjects. 
	temp = {};
	for i = 1:length(study)
		for j = 1:length(task)
			[a tempT] = system(sprintf('ls /mindhive/saxelab2/%s/*/results/%s -dpm',study{i},task{j}));
			tempT = regexp(tempT,',','split');
            tempT{end} = tempT{end}(1:end-1);
			temp = {temp{:} tempT{:}};
		end
	end
	newtemp = {};
	fftemp = {};
	for i=1:length(temp)
		if temp{i}(end) == '/' | temp{i}(end-1) == '/'
			theSubj = regexp(temp{i},'/','split');
			fftemp{end+1} = temp{i};
			newtemp{end+1} = [theSubj{end-3:end}];
		end
	end
	temp2 = arrayfun(@(x)({regexprep(x{:},'results',' - ','once')}),newtemp);
	switch type
		case {1,3}
			tsubjects = listdlg('ListSize',[300 600],'SelectionMode','multiple','PromptString','Select Subjects','ListString',temp2);
			subjects{1} = fftemp(tsubjects);
		case {2,4}
			tsubjects = listdlg('ListSize',[300 600],'SelectionMode','multiple','PromptString','Select Group 1 Subjects','ListString',temp2);
			subjects{1} = fftemp(tsubjects);
			tsubjects = listdlg('ListSize',[300 600],'SelectionMode','multiple','PromptString','Select Group 2 Subjects','ListString',temp2);
			subjects{2} = fftemp(tsubjects);
    end
else
    if iscell(varargin{5})
		subjects = {};
		% if they specify the subjects, presume that they are only
		% concerned with one task in one study. 
        if iscell(varargin{5}{1})
            for j=1:length(varargin{5})
                for i=1:length(varargin{5}{j})
                    subjects{j}{i} = sprintf(' /mindhive/saxelab2/%s/%s/results/%s/',study{1},varargin{5}{j}{i},task{1});
                end
            end
        else
            for i=1:length(varargin{5})
                subjects{i} = sprintf(' /mindhive/saxelab2/%s/%s/results/%s/',study{1},varargin{5}{i},task{1});
            end
            subjects = {subjects};
        end
    end
end

if type == 3 || type == 4
	% specify the covariates
	covariate_name = inputdlg('Please name your covariate of interest');
	input_method = questdlg('How do you wish to input your covariate of interest?','Covariate Input','One value at a time','As a vector','One value at a time');
	switch  input_method
		case 'One value at a time'
			covariate = [];
			for grp=1:length(subjects)
				for subj=1:length(subjects{grp})
					temp = regexp(subjects{grp}{subj},'/','split');
					covariate(end+1) = input(sprintf([temp{end-3} '\t']));
				end
			end
		case 'As a vector'
			for grp=1:length(subjects)
				for subj=1:length(subjects{grp})
					temp = regexp(subjects{grp}{subj},'/','split');
					fprintf([temp{end-3} '\n']);
				end
			end
			while 1
				covariateT = inputdlg('Input vector (include brackets)');
				covariate = eval(covariateT{:});
				if length(covariate) ~= numel([subjects{:}])
					questdlg('The number of covariates you input does not match the number of subjects.','Okay','Okay');
				else
					break;
				end
			end
	end
end
analysis_name = inputdlg('Enter a name for this RFX analysis.');

% all necessary inputs have been acquired

%% ===================== Move Images ============================
% First, make the RFX analysis folder. This is in the first study folder
% selected by the user. 
fprintf('Creating directory for analysis...\n');
expDir = ['/mindhive/saxelab2/' study{1}];
cd(expDir);
if ~exist('RandomEffects','dir')
	mkdir('RandomEffects');
end
cd RandomEffects
% going to try to get this to work without these
%if any(analysis_name{:} == '>')
%    analysis_name = {regexprep(analysis_name{:},'>',' greater than ')};
%elseif any(analysis_name{:} == '<')
%    analysis_name = {regexprep(analysis_name{:},'<',' less than ')};
%end
mkdir(analysis_name{:});
cd(analysis_name{:});
expDir = pwd; 

imstocopy = numel([subjects{:}]);
fprintf('Copying Images\n');
fprintf('Copying image . . . ');
im_count = 0;
% iterate over subjects -- this may become a problem if a given subject has
% BOTH tasks present. Nonetheless, I don't expect this will be a terribly
% large problem. 
thelen = 0;
for grp=1:length(subjects)
	for subj=1:length(subjects{grp})
        try 
            cd(subjects{grp}{subj}(2:end));
        catch
            cd(subjects{grp}{subj}(1:end));
        end
        tsub = regexp(subjects{grp}{subj},'/','split');
        tsub = tsub{5};
		load('SPM.mat');
		im_count = im_count + 1;
        fprintf(repmat('\b',1,thelen));
		strin = sprintf('%.0f/%.0f',im_count,imstocopy);
		fprintf(strin);
		switch con_type
			case 1
				% they are using a numeral
                try
                    con_file = SPM.xCon(contrast).Vcon.fname;
                    con_descript = SPM.xCon(contrast).Vcon.descrip;
                catch
                    fprintf('Couldn''t find the xCon field in the SPM file for subject #%d...looking for the actual image...',subj);
                    try 
                        man_con_file = dir(sprintf('con_%04d.img',contrast));
                        con_file = man_con_file(1).name;
                        fprintf('found it!\n\n\n\n');
                    catch
                        fprintf('\nCouldn''t find an appropriate file...terminating.\n');
                        return;
                    end
                end
			case 2
				% they are using a string
				for con = 1:length(SPM.xCon)
					if strfind(upper(SPM.xCon(con).Vcon.descrip),upper(contrast))
						con_file = SPM.xCon(con).Vcon.fname;
                        con_descript = SPM.xCon(con).Vcon.descrip;
						break;
					end
				end
        end
        num_sessions = length(SPM.nscan); 
		clear SPM;
		%copy_cmd_img = sprintf('!cp %s%s %s/%s_grp_%s_sub.img',subjects{grp}{subj}(2:end),con_file,expDir,num2str(grp),num2str(subj));
		%copy_cmd_hdr = sprintf('!cp %s%s %s/%s_grp_%s_sub.hdr',subjects{grp}{subj}(2:end),regexprep(con_file,'.img','.hdr'),expDir,num2str(grp),num2str(subj));
		% just copy it via imcalc
		f = sprintf('i1/%d',num_sessions);
		Vi = spm_vol(con_file);
		Q = sprintf('%s/%s_grp_%s_con_%s.img',expDir,num2str(grp),tsub,con_descript);
		Vo = struct('fname',Q,'dim',Vi(1).dim(1:3), 'dt', [spm_type('float32'), 1],'mat',Vi(1).mat,'descrip','spm - algebra','mask',1);
		spm_imcalc(Vi,Vo,f);
		P{im_count} = sprintf('%s/%s_grp_%s_con_%s.img',expDir,num2str(grp),tsub,con_descript);
		% eval(copy_cmd_img);
		% eval(copy_cmd_hdr);
		thelen = length(strin);
	end
end
fprintf('\nImages copied successfully!\n');
end
cd(expDir);
save('RFX_state');


%% ===================== Begin RFX Analysis ============================
SPM.xY.P		= P';
SPM.xY.VY		= spm_vol(char(P));
iGMsca			= 9;								% no grand mean scaling
M_X				= 0;								% no masking
iGXcalc			= 1;								% omit global calculation
sGXcalc			= 'omit';
sGMsca			= '<no grand Mean scaling>';
sGloNorm		= '<no global normalisation>';

spm_defaults;

I = ones(length(P),4);
for i=1:length(P),I(i,1)=i;end 
D = spm_spm_ui('DesDefs_Stats');
H = [];B = [];C = [];G = [];
Hnames = {};Bnames = {}; Cnames = {}; Gnames = {};
% Thus far it appears that the substantial differences between types of
% RFX analysis is that they have different D structures and regressor
% matricies; everything else stays much the same. 
switch type
	case 1
		D = D(1);
		H = ones(length(P),1);
		Hnames = {'mean'};
	case 2
		D = D(2);
		H = [ones(1,length(subjects{1})) zeros(1,length(subjects{2}));
			 zeros(1,length(subjects{1})) ones(1,length(subjects{2})) ]';
		B = ones(numel([subjects{:}]),1);
		C = [];
		G = [];
		[toss Hnames] = spm_DesMtx('sca',H,{'Group 0','Group 1'});
		Bnames = {'mean'};
	case 3
		D = D(7);
		B = ones(numel([subjects{:}]),1);
		C = covariate';
		Bnames = {'mean'};
		Cnames = covariate_name;
	case 4
		D = D(8); % multiple regression...is this right?
		H = [ones(1,length(subjects{1})) zeros(1,length(subjects{2}));
			 zeros(1,length(subjects{1})) ones(1,length(subjects{2})) ]';
		B = ones(numel([subjects{:}]),1);
		C = covariate';
        [toss Hnames] = spm_DesMtx('sca',H,{'Group 0','Group 1'});
		Bnames = {'mean'};
		Cnames = covariate_name;
end
if size(B,2)~=1
	B = reshape(B,[],1);
end
X = [H C B G];
tmp    = cumsum([size(H,2), size(C,2), size(B,2), size(G,2)]);
SPM.xX     = struct(	'X',		X,...
	'iH',		[1:size(H,2)],...
	'iC',		[1:size(C,2)] + tmp(1),...
	'iB',		[1:size(B,2)] + tmp(2),...
	'iG',		[1:size(G,2)] + tmp(3),...
	'name',		{[Hnames; Cnames; Bnames; Gnames]},...
	'I',		I,...
	'sF',		{D.sF});
tmp = {	sprintf('%d condition, +%d covariate, +%d block, +%d nuisance',...
	size(H,2),size(C,2),size(B,2),size(G,2));...
	sprintf('%d total, having %d degrees of freedom',...
	size(X,2),rank(X));...
	sprintf('leaving %d degrees of freedom from %d images',...
	size(X,1)-rank(X),size(X,1))				};
SPM.xsDes = struct(	'Design',			{D.DesName},...
	'Global_calculation',		{sGXcalc},...
	'Grand_mean_scaling',		{sGMsca},...
	'Global_normalisation',		{sGloNorm},...
	'Parameters',			{tmp}			);

% scan number
SPM.nscan	= size(SPM.xX.X,1);

% save progress in cwd
save SPM SPM

% And now give it a shot:
fprintf('Estimating Design for %d subjects\n',length(P));
SPM = spm_spm(SPM);

% Finally, let's produce the contrasts.
con_vals = [zeros(1,size(SPM.xX.X,2)-1) 1];
con_name = 'Mean value';
fprintf('Creating Contrasts for %d subjects\n',length(P));
SPM.xCon = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);

switch type
	case 2
		con_vals = [1 -1 0];
		con_name = 'Group 1 versus Group 2';
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
		con_vals = [-1 1 0];
		con_name = 'Group 2 versus Group 1';
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
	case 3
		con_vals = [1 0];
		con_name = sprintf('%s versus rest',covariate_name{:});
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
	case 4
		con_vals = [1 -1 0 0];
		con_name = 'Group 1 versus Group 2';
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
		con_vals = [-1 1 0 0];
		con_name = 'Group 2 versus Group 1';
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
		con_vals = [0 0 1 0];
		con_name = sprintf('%s versus rest',covariate_name{:});
		SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals',SPM.xX.xKXs);
end

spm_contrasts(SPM);
% D(1) = one way T test
% D(2) = two way T test
%	- it goes to line 708
%	- then to 1515
%	- then 1652
%	- line 835 is important
% covariates appear to be obtained starting at line 884
% call to spm function (not spm itself) at 1259
% line 1473: the spm structure is assembled and prepared.
% D(7) = simple regression

end