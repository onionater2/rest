function get_PSC_from_ROI(study, task, varargin)
% e.g. get_PSC_from_ROI('EIB', 'EIB_main_with_art_reg_results_normed')
% or e.g. get_PSC_from_ROI('EIB', 'EIB_main_with_art_reg_results_normed', makeIDs('EIB, [4:10,12:19]))
%%%% OTHER NECESSARY IN SCRIPT PARAMETERS INCLUDING WIN_SECS, MEANWIN, and ROILIST
%AES march 2013
%%too lazy to use roi_batch?
%%figure out which subjects have a given ROI, then call roi_batch_amy_with_plots to extract PSC for those subjects in that ROI (and plot it!).

rootdir=['/mindhive/saxelab2/' study '/'];
cd(rootdir)

%%set these things for your study
win_secs=18;
onsetdelay=6;
highpass=1; 
meanwin='6:16';


IDstring=['SAX_' study '_*'];
if numel(varargin)>0
    searchIDs=varargin{1}
else
searchIDs=adir(IDstring);
end

searchN=length(searchIDs);

group=1;
% this is ghetto for group ROIS
ROIlist={
    'functional/EIBrois/ROI_rinsula_wfu_xyz',...
    'functional/EIBrois/ROI_rvSTR_reward_xyz',...
    'functional/EIBrois/ROI_vmPFC_reward_xyz',...
    'functional/EIBrois/ROI_right_ant_temporal_xyz',...
    'functional/EIBrois/ROI_ramygdala_wfu_xyz',...
    'functional/EIBrois/ROI_MPFC_peelenpeak_xyz',...
    'functional/EIBrois/ROI_lSTS_peelenpeak_xyz',...
    'functional/EIBrois/ROI_lvSTR_reward_xyz',...
    'functional/EIBrois/ROI_linsula_wfu_xyz',...
    'functional/EIBrois/ROI_left_ant_temporal_xyz',...
    'functional/EIBrois/ROI_lamygdala_wfu_xyz'
    };
% 
ROIloclist={
      'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed'};
%it doesn't actually use this loc task info but you have to put something
% %here because the script is dumb
  
%list of ROIs
% ROIlist={
%      'RTPJ','RSTS', 'LTPJ', 'LSTS', 'MMPFC', 'DMPFC', 'PC',...  
%      'rSTS_kanparcelFaceObj', 'lSTS_kanparcelFaceObj', 'rFFA_kanparcelFaceObj', 'lFFA_kanparcelFaceObj', 'rOFA_kanparcelFaceObj', 'lOFA_kanparcelFaceObj', 'rpSTS_BDbiomotBioObj', 'lLOC_foundObjFace', 'rLOC_foundObjFace'
%      };
% ROIloclist={
%      'tomloc_with_art_reg_results_normed','tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed', 'tomloc_with_art_reg_results_normed',...  
%      'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed', 'EmoBioLoc_with_art_reg_results_normed','EmoBioLoc_with_art_reg_results_normed','EmoBioLoc_with_art_reg_results_normed'
%      };
%
numROIs=length(ROIlist);

%% go through ROIS
for r=1:numROIs
	roiName=ROIlist{r};
	roiCount=0;
    ROIsubj={};

	%% make cell array for each ROI of the subjects that have the ROI
	for n=1:searchN
		subject=searchIDs{n};
		subjDir=[rootdir subject '/roi/'];
        if exist(subjDir)
        cd(subjDir)
        if group==0;
		if ~isempty(dir(['*' roiName '*']))
		roiCount=roiCount+1;
		ROIsubj{roiCount}=[rootdir subject];
        end
        else
            roiCount=roiCount+1;
            ROIsubj{roiCount}=[rootdir subject];
        end
        end
    end
    
    disp(['found ' num2str(roiCount) '_subjects with valid roi for ' roiName '. extracting PSC for task ' task ' now....']);
task_dir=['results/' task '/'];
loc_dir=['results/' ROIloclist{r} '/'];
addpath('/mindhive/saxelab/scripts/aesscripts')
cd(rootdir)
roi_batch_amy_with_plots(ROIsubj,ROIlist{r},task_dir, loc_dir, win_secs, onsetdelay, highpass, meanwin, group)

end


end
