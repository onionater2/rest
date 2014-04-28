function printresults2csv(analysisname)

rootdir='/mindhive/saxelab2/EIB/EIB_mvpa';
analysisdir=[rootdir '/' analysisname];
cd(analysisdir);
individual=dir('*ind.mat')
group=dir('*group.mat')

% indROIs = {
%      'RTPJ_tomloc','RSTS_tomloc', 'LTPJ_tomloc', 'LSTS_tomloc', 'MMPFC_tomloc', 'DMPFC_tomloc', 'PC_tomloc',...  
%      'rSTS_kanparcelFaceObj_EmoBioLoc', 'lSTS_kanparcelFaceObj_EmoBioLoc', 'rFFA_kanparcelFaceObj_EmoBioLoc', 'lFFA_kanparcelFaceObj_EmoBioLoc', 'rOFA_kanparcelFaceObj_EmoBioLoc', 'lOFA_kanparcelFaceObj_EmoBioLoc', 'rpSTS_BDbiomotBioObj_EmoBioLoc', 'lLOC_foundObjFace', 'rLOC_foundObjFace'
%      };
 
groupROIs={'lSTS_peelenpeak', 'MPFC_peelenpeak', 'rinsula_wfu', 'linsula_wfu', 'rvSTR_reward', 'lvSTR_reward','ramygdala_wfu','lamygdala_wfu', 'right_ant_temporal','left_ant_temporal','vmPFC_reward'};

condition_names_all={
    {'pos_all_vsr','neg_all_vsr'},...
    {'pos_p_vsr','neg_p_vsr'},...
    {'pos_c_vsr','neg_c_vsr'},...
    {'fake_pos_vsr','fake_neg_vsr'},...
    {'possocial_vsr', 'negsocial_vsr'},...
    {'posnonsoc_vsr', 'negnonsoc_vsr'},...
    {'posmale_vsr', 'negmale_vsr'},...
    {'posfema_vsr', 'negfema_vsr'},...
    {'fake_poscontext_vsr', 'fake_negcontext_vsr'},...
    {'fake_posperson_vsr', 'fake_negperson_vsr'},...
    {'social_vsr', 'nonsoc_vsr'},...
    {'cartoon_vsr', 'persons_vsr'},... 
    {'gendermale_vsr', 'genderfema_vsr'},...
    {'pos_all_vso','neg_all_vso'},...
    {'pos_p_vso','neg_p_vso'},...
    {'pos_c_vso','neg_c_vso'},...
    {'fake_pos_vso','fake_neg_vso'},...
    {'possocial_vso', 'negsocial_vso'},...
    {'posnonsoc_vso', 'negnonsoc_vso'},...
    {'posmale_vso', 'negmale_vso'},...
    {'posfema_vso', 'negfema_vso'},...
    {'fake_poscontext_vso', 'fake_negcontext_vso'},...
    {'fake_posperson_vso', 'fake_negperson_vso'},...
    {'social_vso', 'nonsoc_vso'},...
    {'cartoon_vso', 'persons_vso'},... 
    {'gendermale_vso', 'genderfema_vso'}
    };

f=fopen('summary','w');
    fprintf(f, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'analysis', ',', 'ROI', ',', 'discrimination', ',', 'contrast', ',', 'within', ',', 'across', ',', 'T', ',', 'p');
    fprintf(f,'\n');
mat=load(individual.name, 'mvpa_stats');
%resultsmat=eval('mat.mvpa_stats')
indROIs=fieldnames(mat.mvpa_stats)
numROIs=length(indROIs);
for i=1:numROIs
    roiname=indROIs{i};
    roimat=eval(['mat.mvpa_stats.' roiname]);
    discriminations=fieldnames(roimat)
    numDiscriminations=length(discriminations);
   for x=1:numDiscriminations
      condition=discriminations{x};
      contrast=condition(end-2:end);
      
      condmat=eval(['mat.mvpa_stats.' roiname '.' condition]);
      results=condmat(:)';
    fprintf(f, '%s %s %s %s %s %s %s', analysisname, ',', roiname, ',', condition, ',', contrast, ',', results);
   end
end

mat2=load(group.name, 'mvpa_stats');
%resultsmat=eval('mat2.mvpa_stats')
groupROIs=fieldnames(mat2.mvpa_stats)
numROIs=length(groupROIs);
for i=1:numROIs
    roiname=groupROIs{i};
    roimat=eval(['mat2.mvpa_stats.' roiname]);
    discriminations=fieldnames(roimat)
    numDiscriminations=length(discriminations);
   for x=1:numDiscriminations
      condition=discriminations{x};
      contrast=condition(end-2:end);
      
      condmat=eval(['mat2.mvpa_stats.' roiname '.' condition]);
      results=condmat(:)';
    fprintf(f, '%s %s %s %s %s %s %s', analysisname, ',', roiname, ',', condition, ',', contrast, ',', results);
   end
end

end
    