function autoROI_extract_betasonly(study,subjects,task,suffix,rois,uconfig)
%e.g. autoROI_extract_betasonly('FSF', makeIDs('FSF', [1:19]),
%'FSF_main_with_art_reg_results_normed', '_mushedbinary')
%note you need to remove the suffix from the results dirs when running this script. FIX THIS.
%edited by AES for contexts in which PSC doesn't make sense and you just
%want betas

%-------------------------------------------------------------------------%
% CONFIGURATION
%-------------------------------------------------------------------------%
config.remove_artifacts     = 1;
config.remove_outliers      = 0; 
config.intensity_thresh     = 3;  
config.group_rois           = 0;
config.runs                 = 'all'; % integer, or 'all'
config.n_assumed_runs       = 8; % maximum number of runs the in the study

if exist('uconfig','var')&&~iscell(uconfig)
    fprintf('\n\tWARNING: Your user configuration is not a cell array!\n');
end
if exist('uconfig','var')&&iscell(uconfig) % then they've included a custom configuration
    uco = fieldnames(config); % uco = user-configurable options
    for ovs = 1:2:length(uconfig)
        cov = uconfig([ovs,ovs+1]); % current configuration parameter-value pair
        dne = 0; % if 1, 'do not evaluate'
        if ~ischar(cov{1})
            warning('Extra variable %i is not a string',(ovs+1)/2);
            dne = 1;
        end
        % validation step 2: ensure that cov{1} is a variable that can be 
        % changed
        if ~dne&&~any(strcmp(cov{1},uco))
            warning('%s is not a user-configurable parameter',cov{1});
            dne = 1;
        end
        if ~dne
            config.(cov{1}) = cov{2};
        end
    end
end
config = config; % ??? < what is this here for?
%-------------------------------------------------------------------------%
% STUDY
%-------------------------------------------------------------------------%
if (~nargin||(exist('study','var')&&isempty(study)))
    % no study has been specified
    study = inputdlg('What is the study name?');
    if isempty(study)
        study = '*';
    end
    pos_stu = adir(fullfile('/mindhive','saxelab*',['*' study{:} '*']));
    if ~iscell(pos_stu)
        pos_stu = adir(fullfile('/*','saxelab*',study{:}));
        if ~iscell(pos_stu)
            error('Could not locate study.\n');
        end
    end
    if length(pos_stu) > 1
        % the user must disambiguate which study they wish
        study = pos_stu(listdlg('ListString',pos_stu,'SelectionMode','single','PromptString','Multiple studies found, please choose one','ListSize',[500,300]));
        if isempty(study)
            error('No study chosen.\n');
        end
    else
        study = pos_stu;
    end
else
    if iscell(study)
        study = study{:};
    end
    pos_stu = adir(fullfile('/mindhive','saxelab*',['*' study '*']));
    if ~iscell(pos_stu)
        pos_stu = adir(fullfile('/*','saxelab*',study));
        if ~iscell(pos_stu)
            error('Could not locate study.\n');
        end
    end
    if length(pos_stu) > 1
        % the user must disambiguate which study they wish
        study = pos_stu(listdlg('ListString',pos_stu,'SelectionMode','single','PromptString','Multiple studies found, please choose one','ListSize',[500,300]));
        if isempty(study)
            error('No study chosen.\n');
        end
    else
        study = pos_stu;
    end
end
while iscell(study)
    study = study{:};
end
cd(study);
%-------------------------------------------------------------------------%
% SUBJECTS
%-------------------------------------------------------------------------%
if ~exist('subjects','var')||isempty(subjects)
    % have them pick subjects
    pos_sub = adir('*/results/*/SPM.mat');
    pos_sub = unique(cellfun(@(x) x{1}, regexp(pos_sub,'/','split'),'UniformOutput',false));
    if ~iscell(pos_sub)
        error('Could not locate subject(s)\n');
    elseif length(pos_sub) > 1
        subjects = pos_sub(listdlg('ListString',pos_sub,'SelectionMode','multiple','PromptString','Multiple subjects found, please choose desired subjects','ListSize',[300,300]));
    else
        subjects = pos_sub;
    end
elseif ~iscell(subjects)&&ischar(subjects)
    % find all available subjects that match a given criteria
    subjects = adir(['*' subjects '*']);
end
%-------------------------------------------------------------------------%
% TASK
%-------------------------------------------------------------------------%
% for task, we're going to compile a list of all available tasks that exist
% across all subjects
if ~exist('task','var')||isempty(task)
    null = unique(adir(fullfile(subjects{1},'results','*')));
    res_dirs = cellfun(@(x) x{end},regexp(null,'/','split'),'UniformOutput',false);
    for i = 2:length(subjects)
        null = unique(adir(fullfile(subjects{i},'results','*')));
        null = cellfun(@(x) x{end},regexp(null,'/','split'),'UniformOutput',false);
        res_dirs = intersect(res_dirs,null);
    end
    task = res_dirs(listdlg('ListString',res_dirs,'SelectionMode','single','PromptString','Please select the task','ListSize',[500,300]));
end
while iscell(task)
    task = task{:};
end
%-------------------------------------------------------------------------%
% ROIS
%-------------------------------------------------------------------------%
if ~config.group_rois
    if ~exist('rois','var')||isempty(rois)
        rois = {};
        for i = 1:length(subjects)
            null = unique(adir(fullfile(subjects{i},'autoROI','*.mat')));
            if iscell(null)
                null = cellfun(@(x) x{end},regexp(null,'/','split'),'UniformOutput',false);
                rois = [rois null];
            end
        end
        rois = unique(rois);
        rois = rois(listdlg('ListString',rois,'SelectionMode','multiple','PromptString','Please select the ROIs','ListSize',[500,300]));
    end
else
    if ~exist('rois','var')||isempty(rois)
        rois = cellstr(spm_select([1 Inf],'mat','Select ROI xyz files'));
    end
end
%-------------------------------------------------------------------------%
% BEGIN EXTRACTION
%-------------------------------------------------------------------------%
% Iterate over subjects
for s = 1:length(subjects)
    cur_sub = subjects{s};
    fprintf('Subject: %s\n',cur_sub);
    fprintf('\tLoading ROIs...\n');
    % locate all of this subject's ROIs...
    cur_rois = {};
    roi_names = {};
    roi_points = [];
    for i = 1:length(rois)
        if ~config.group_rois
            null = adir(fullfile(cur_sub,'autoROI',rois{i}));
        else
            null = rois(i);
        end
        if iscell(null)
            cur_rois{end+1} = null{1};
            roi_names{end+1} = rois{i};
            null = load(cur_rois{end});
            if ~isfield(null,'roi_XYZ')
                if isfield(null,'roi_xyz')
                    load(cur_rois{end},'roi_xyz');
                    roi_XYZ = roi_xyz;
                    %null = spm_vol(fullfile(study,cur_sub,'results',task,'beta_0001.img'));
                    null = spm_vol(fullfile(study,cur_sub,'results',task,suffix,'beta_0001.img'));
                    roi_XYZ = mm2vox(roi_XYZ,null);
                else
                    error('can''t interpret ROI file...\n');
                end
            else
                load(cur_rois{end},'roi_XYZ');
            end
            roi_XYZ(:,4) = i;
            roi_points = [roi_points; roi_XYZ];
        end
    end
    if ~isempty(roi_points)
    % load the SPM file
    fprintf('\tLoading SPM...\n');
    load(fullfile(cur_sub,'results',[task suffix],'SPM.mat'));
    fprintf('\tLoading artifacts...\n');
    bdirs = unique(cellfun(@(x) fileparts(x), cellstr(SPM.xY.P),'UniformOutput',false));
    skp = 0;
    arts = [];
    for bdir = 1:length(bdirs)
        file = adir(fullfile(bdirs{bdir},'art_regression_outliers_[^a]*'));
        if iscell(file)
            art_tmp = load(file{1});
            art_tmp2 = zeros(size(art_tmp.R,1),1);
            art_tmp2(find(sum(art_tmp.R,2))) = 1;
        else
            art_tmp2 = zeros(SPM.nscan(bdir),1);
        end
        arts = [arts; art_tmp2];
    end
    arts_rem = zeros(1,length(cur_rois));
%    remove artifact timepoints, if requested
    if config.remove_artifacts
        arts_rem = arts_rem + sum(arts);
    end
    if config.remove_outliers
        for r = 1:size(arts_rem,1)
            arts_rem(r) = arts_rem(r)+sum(zs>config.intensity_thresh);
        end
    end
    mkdir('ROI');
    owd = pwd;
    desireddir=[owd, '/',cur_sub,'/results/', task, suffix]%AES edit
    cd(desireddir);%
    %cd(SPM.swd);
    conds = {};
    for sessn = 1:length(SPM.Sess)
        conds = [SPM.Sess(sessn).U.name conds];
    end
    conds = unique(conds);
    betadata = {};
    roi_mapping = unique(roi_points(:,4));
    for r = 1:length(roi_names)        
        betadata_mini = [];
        crname = strrep(roi_names{r},'_xyz.mat','');
        null = regexp(crname,'/','split');
        crname = null{end};
        cur_points = roi_points(roi_points(:,4)==roi_mapping(r),1:3);
        for sessn = 1:length(SPM.Sess)
            sess_conds = [SPM.Sess(sessn).U.name];
            for sess_condn = 1:length(sess_conds)
                sess_cond_ind = find(strcmp(conds,sess_conds{sess_condn}));
                x = SPM.Vbeta(SPM.Sess(sessn).col(sess_condn));
                betadata_mini(sess_cond_ind,sessn) = nanmean(spm_sample_vol(x,cur_points(:,1),cur_points(:,2),cur_points(:,3),0));
            end
        end
        betadata_mini(:,end+1) = nanmean(betadata_mini,2);
        for condn = 1:size(betadata_mini,1)
            betadata{condn,1} = cur_sub;
            betadata{condn,2} = arts_rem(r);
            betadata{condn,3} = crname;
            betadata{condn,4} = conds{condn};
            for runn = 1:size(betadata_mini,2)
                betadata{condn,runn+4} = betadata_mini(condn,runn);
            end
        end        
        fname = fullfile(owd,['ROI/BETA_' crname '_' task '_' date '_' suffix '.csv']);
        n_assumed_runs = config.n_assumed_runs;
        if ~exist(fname,'file')
            f = fopen(fname,'w');
            fprintf(f,'subject,artifacts removed,roi,condition,');
            fprintf(f,'Run %i,',1:n_assumed_runs);
            % there was some confusion being caused by the fact that some
            % subjects have 4 runs while others have 3, making it look like
            % the mean value for runs 1-3 in subjects who only have 3 runs
            % was the value for the 4th run...so for now we're just going
            % to assume that all subjects have 8 or less runs. it's not the
            % best, I know, but it's as good as we can get right now. 
            fprintf(f,'Mean\n');
        else
            f = fopen(fname,'a'); 
        end
        for entryn = 1:size(betadata,1)
            tbd = betadata(entryn,:);
            fprintf(f,'%s,%i,%s,%s',tbd{1:4});
            fprintf(f,',%.4f',tbd{5:end-1});
            if numel(tbd(5:end-1)) < n_assumed_runs
                fprintf(f,repmat(',',1,n_assumed_runs-numel(tbd(5:end-1))));
            end
            fprintf(f,',%.4f',tbd{end});
            fprintf(f,'\n');
        end
        fclose all;
    end
    cd(owd);
    end
end
end
