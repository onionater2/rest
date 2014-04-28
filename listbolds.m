function runs=listbolds(task, subjects, varargin)
%e.g. runs=listbolds('tomloc', makeIDs('EIB', [10:13]), 'EIB')
%third study parameter is optional, assumes EIB (for backwards
%compatibility) if no study is provided
%% created by AES 3/26/13
%%takes as input a task and a cell array of subjects, prints cell array of
%%relevant bold directories
%% meant to be called as argument for other modeling scripts

if nargin>2
    study=varargin{1};
    filename=['/mindhive/saxelab2/', study, '/', study, '_subject_taskruns.mat'];
else
    filename=['/mindhive/saxelab2/EIB/EIB_subject_taskruns.mat'];
end
load(filename);
numSubjects=size(s,2);

for i=1:length(subjects)
   
    subjID= subjects{i};
    for x=1:numSubjects
        subjIDmatch=s(x).ID;
        if strcmp(subjID,subjIDmatch)
           r=eval(['s(x).' task]);
           if ~isempty(r)
           runs{i}=r;
           else
           runs{i}=[];
            disp(['runs found not for for task ' task ' for subject ' subjID])
           end
        end
    
    end

end
end