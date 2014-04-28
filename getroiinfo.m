function report=getroiinfo(study, subjectlist)
rois={'rFFA', 'lFFA', 'rOFA', 'lOFA', 'rSTS', 'lSTS', 'RTPJ', 'LTPJ', 'PC', 'RSTS', 'LSTS', 'VMPFC', 'MMPFC', 'DMPFC'};
numrois=length(rois)
roidir='autoROI';
rootdir='/mindhive/saxelab2/'
studydir=[rootdir, study, '/']
numsubjs=length(subjectlist);
subjdata=load([studydir, 'EIB_subject_taskruns.mat']);
for r=1:numrois
    report(r).name=rois{r};
    report(r).numvoxels=zeros(numsubjs,1);
    report(r).peakT=zeros(numsubjs,1);
    report(r).peakXYZ=zeros(numsubjs,3);
    report(r).subjectlist=[];
    report(r).ASD=[];
end
for s=1:numsubjs
    subject=subjectlist{s}
    asdornt=NaN;
    for x=1:size(subjdata.s,2)
        if strcmp(subjdata.s(x).ID,subject)
            asdornt=subjdata.s(x).ASD;
        end
    end
    subjectdir=[studydir, subject, '/']
    for r=1:numrois
       roi=rois{r}
       report(r).ASD=[report(r).ASD; asdornt];
       report(r).subjectlist=[report(r).subjectlist; subject];
       desiredroi=[subjectdir, roidir, '/*', roi, '*.mat']
       files=dir(desiredroi)
       if length(files)>1
           warning=['muliple roi matches for ', roi, ' for subject ', subject]
           report(r).numvoxels(s)=NaN;
           report(r).peakT(s)=NaN;
           report(r).peakXYZ(s,1)=NaN;
           report(r).peakXYZ(s,2)=NaN;
           report(r).peakXYZ(s,3)=NaN;
       else if length(files)<1
           warning=['no roi matches for ', roi, ' for subject ', subject]
           report(r).numvoxels(s)=NaN;
           report(r).peakT(s)=NaN;
           report(r).peakXYZ(s,1)=NaN;
           report(r).peakXYZ(s,2)=NaN;
           report(r).peakXYZ(s,3)=NaN;
       else
       file=files(1).name
       mat=load([subjectdir, roidir, '/', file])
       report(r).numvoxels(s)=mat.n_vox;
       report(r).peakT(s)=mat.peak_T;
       report(r).peakXYZ(s,1)=mat.peak_xyz_mm(1);
       report(r).peakXYZ(s,2)=mat.peak_xyz_mm(2);
       report(r).peakXYZ(s,3)=mat.peak_xyz_mm(3);
           end
       end
    end 
end
save([studydir, 'roi_report.mat'], 'report')
end