function motion = build_motion_report(study,subjects)
%old nick script
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% motion = build_motion_report(study[, subjects])
% - displays three bar graphs for each subject, for the mean translation, 
%   rotation, and artifacts (if available). Subjects is an optional input. 
% - returns 'motion', a subjects x 3 matrix with these mean values. 
% - data are returned as MEAN value per run. If no data exists for any runs
%   for a subject, a 'nan' is returned in motion
% - rotation is in degrees
%
% EXAMPLES
%        build_motion_report('JKH_DKIDS')
%        build_motion_report('JKH_DKIDS','SAX_DKIDS_07')
%        build_motion_report('JKH_DKIDS',{'SAX_DKIDS_07','SAX_DKIDS_08'})
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

if ~nargin
    help build_motion_report
end
if ~ischar(study)
    error('STUDY input must be a string.');
end
if exist('subjects','var')
    if ~ischar(subjects)&&(~iscell(subjects)||~ischar(subjects{1}))
        error('SUBJECTS must be a string, or cell array of strings.');
    end
end
% determine root directory
root = adir(['/mindhive/saxelab*/' study]);
if ~iscell(root)
    error(sprintf('Could not locate study %s',study));
end
root = root{1};
if ~exist('subjects','var')
    subjects = adir(fullfile(root,'SAX*'));
    subjects = subjects(arrayfun(@(x) isdir(x{:}),subjects));
    subjects = cellfun(@(x) x{end},cellfun(@(y) regexp(y,'/','split'),subjects,'UniformOutput',false),'UniformOutput',false);
elseif ~iscell(subjects)
    subjects = {subjects};
end
subj_nums = cellfun(@(x) x{end},cellfun(@(y) regexp(y,'_','split'),subjects,'UniformOutput',false),'UniformOutput',false);
% now iterate over the subjects, looking for motion parameters. 
motion = zeros(length(subjects),3);
for i = 1:length(subjects)
    subj = subjects{i};
    fprintf('Subject %s\n',subj);
    bolds = adir(fullfile(root,subj,'bold','*'));
    if ~iscell(bolds)
        motion(i,:) = [NaN NaN NaN];
    else
        rp_files  = {};
        art_files = {};
        for j = 1:length(bolds)
            rp_file = adir(fullfile(bolds{j},'rp*.txt'));
            art_file = adir(fullfile(bolds{j},'art_regression_outliers*.mat'));
            if iscell(rp_file)
                rp_files{end+1} = rp_file{1};
            end
            if iscell(art_file)
                art_files{end+1} = art_file{2};
            end
        end
        mot = [];
        art = [];
        if isempty(rp_files)
            motion(i,[1 2]) = [NaN NaN];
        else
            for j = 1:length(rp_files)
                mot = [mot; diff(importdata(rp_files{j}),[],1)];
            end
            mot = [mot(:,1) mot(:,4); ...
                   mot(:,2) mot(:,5); ...
                   mot(:,3) mot(:,6)];
        end
        motion(i,[1 2]) = nanmean(abs(mot));
        if isempty(art_files)
            motion(i,3) = NaN;
        else
            for j = 1:length(art_files)
                load(art_files{j});
                art = [art; size(R,2)];
            end
            motion(i,3) = mean(art);
        end
    end
end
motion(:,2) = motion(:,2)*360/(2*pi);
subplot(3,1,1);bar(motion(:,1));ylabel('Translation (mm)');title('Mean Translation / Timepoint');set(gca,'XTick',[])
subplot(3,1,2);bar(motion(:,2));ylabel('Rotation (deg)');title('Mean Rotation / Timepoint');set(gca,'XTick',[])
subplot(3,1,3);bar(motion(:,3));xlabel('Subject #');ylabel('# Artifacts');title('Mean Artifacts / Run');
set(gca,'XTick',1:length(subjects))
set(gca,'XTickLabel',subj_nums)
end