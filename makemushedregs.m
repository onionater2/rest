function makemushedregs(study, task, subjectlist, filekey)
%e.g. makemushedregs('FSF', 'FSF_main', makeIDs('FSF', [1:19], 'FSFuserregs')
both=1; %1 adjusts binary and param, 0 adjusts only binary
excludefacesbin=1; %excludes tp from obj/scene if it is a 1 for face
excludefacesparam=0;%1 sets scene/obj param to 0 if face binary is 1 (matters only if both=1)
%% Load and copy the user regressor .mat files 
EXPERIMENT_ROOT_DIR = '/mindhive/saxelab2';

for subj=1:length(subjectlist)
    subject=subjectlist{subj}
    runlist=listbolds(task, {subject}, 'FSF');
    runlist=runlist{1}
    %file_list=dir(sprintf('%s.%s.*',subject,task));
    num_runs = length(runlist)

for r = 1:num_runs
    thisbold = runlist(r);
    bolddir=[EXPERIMENT_ROOT_DIR,'/',study,'/', subject, sprintf('/bold/0%.2d',thisbold)]
    cd(fullfile(EXPERIMENT_ROOT_DIR,study,subject,sprintf('bold/0%.2d',thisbold)));
    reg_file = dir([filekey '.mat']); 
    load(reg_file.name);
    [bool,obindex]=ismember('ob', reglabels);
    [bool,scindex]=ismember('sc', reglabels);
    [bool,faindex]=ismember('fa', reglabels);
    faces_bin=binregmatrix(:,faindex);
    faces_param=parregmatrix(:,faindex);
    objects_bin=binregmatrix(:,obindex);
    objects_param=parregmatrix(:,obindex);
    scenes_bin=binregmatrix(:,scindex);
    scenes_param=parregmatrix(:,scindex);
    obsc_bin=boolean(objects_bin+scenes_bin);
    if excludefacesbin
        obsc_bin(faces_bin==1)=0;
        facebinreadme=' for binary reg, timepoints where bin_faces==1 are set to 0.'
    else
        facebinreadme=' for binary reg, face timepoints are not excluded.'
    end
    %for each param, take the max of scene or object regressor
    if both
    obsc_param=objects_param;
    for i=1:length(obsc_param)
        if scenes_param(i)>obsc_param(i)
            obsc_param(i)=scenes_param(i);
        end
    end
    if excludefacesparam
        obsc_param(faces_bin==1)=0; %set to 0 where binary face on
        regreadme=['mushed binary and parametric regressors. for parametric regressor, timepoints where bin_faces==1 are set to 0', facebinreadme]
    else
        regreadme=['mushed binary and parametric regressors. for parametric regressor, face timepoints are not excluded.', facebinreadme]
    end
    else
        if excludefacesbin
        regreadme=['mushed binary regressors only. use unmushed userregs if doing parametric analysis.', facebinreadme]
        else
        regreadme=['mushed binary regressors only. use unmushed userregs if doing parametric analysis.', facebinreadme]

        end
    end
    numconds=length(reglabels);
    newreglabels=[];
    newbinregmatrix=[];
    newparregmatrix=[];
    count=0
    for x=1:numconds
        if ~strcmp(reglabels{x},'ob') & ~strcmp(reglabels{x},'sc')
            count=count+1;
            newreglabels{count}=reglabels{x};
            newbinregmatrix=[newbinregmatrix,binregmatrix(:,x)];
            newreg_data(count).binreg=binregmatrix(:,x);
            newreg_data(count).name=reglabels{x};
            if both
            newparregmatrix=[newparregmatrix,parregmatrix(:,x)];
            newreg_data(count).parreg=parregmatrix(:,x);
            end
        end
    end
    count=count+1;
    newreglabels{count}='os';
    newbinregmatrix=[newbinregmatrix,obsc_bin];
    newreg_data(count).binreg=obsc_bin;
    newreg_data(count).name='os';
    if both
    newparregmatrix=[newparregmatrix,obsc_param];
    newreg_data(count).parreg=obsc_param;
    end
reglabels=newreglabels;
binregmatrix=newbinregmatrix;
parregmatrix=newparregmatrix;
reg_data=newreg_data;
save([bolddir,'/FSFuserregs_mushed.mat'], 'reglabels', 'binregmatrix','parregmatrix', 'reg_data', 'regreadme')
end 
end
end