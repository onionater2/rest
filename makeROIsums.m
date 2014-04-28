function str= makeROIsums(report)
for x=1:14
roi=report(x).name;
numvox=report(x).numvoxels;
meannumvox=nanmean(numvox(1:16,:));
stdnumvox=nanstd(numvox(1:16,:));
peakT=report(x).peakT;
peakT=peakT(1:16,:);
peakXYZ=report(x).peakXYZ;
peakXYZ=peakXYZ(1:16,:);
str= sprintf('%s:    %d subjects,     %.1f, %.1f, %.1f,     %.2f voxels,     %.2f std',roi,length(numvox(~isnan(numvox(1:16)))), nanmean(peakXYZ(:,1)),nanmean(peakXYZ(:,2)),nanmean(peakXYZ(:,3)),meannumvox, stdnumvox)
    
%strings{x}=[roi, ': ', num2str(nanmean(numvox)), ' voxels, peak T=' num2str(nanmean(peakT)), ', ', num2str(nanmean(peakXYZ(:,1))), ',', num2str(nanmean(peakXYZ(:,2))), ',' num2str(nanmean(peakXYZ(:,3)))];
end