function add_contrast_to_behav_amy(study, task, subjects, contrastName, runs, values, varargin)

%% aes 12/12/2012

%%forgot to put that contrast in your original code? fix it...
clearexisting=0;
if length(varargin)>0 
    if varargin{1}=='clearexisting'
    clearexisting=1;
    end
end

rootdir=['/mindhive/saxelab2/' study '/behavioural/']; %% 
cd(rootdir);
numSubj=size(subjects,2);
for subj=1:numSubj
    for i=1:length(runs)
    try
    load([subjects{subj} '.' task '.' num2str(runs(i)) '.mat']);
    if clearexisting==1
        clear con_info
    end
      try
        n=size(con_info);
        origNumContrasts=n(2);
      catch
          'no existing con info'
          origNumContrasts=0
      end   
      con_info(origNumContrasts+1).name=contrastName;  
      con_info(origNumContrasts+1).vals=values;
      save([subjects{subj} '.' task '.' num2str(runs(i)) '.mat'],'-append','con_info');
    catch
	  display(['subject ' subjects{subj} ' is missing run ' num2str(i)])
    end
end
end
