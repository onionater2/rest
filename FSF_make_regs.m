function FSF_make_regs(subjectlist)
% created by AES 12/6 to make condition regressors for FSF
rootdir='/mindhive/saxelab2/FSF/'
moviedur=120 %note these are off in actualDur FSF behave file
TR=2
condlist={'me', 'so', 'ph', 'fa', 'ob', 'sc','po','ne'}

for subj=1:length(subjectlist)
    subject=subjectlist{subj}
    runlist=listbolds('FSF_main', {subject}, 'FSF');
    runlist=runlist{1}
for r=1:length(runlist)
    run=runlist(r);
    bolddir=[rootdir, subject, sprintf('/bold/0%.2d',run)]
    behavefile=[rootdir, 'behavioural/', subject '.FSF_main.' num2str(r) '.mat']
    regfile=[rootdir, 'FSF_video_timecourses.mat']
    b=load(behavefile);
    regfile=load(regfile);
    binregmatrix=zeros(b.ips,length(condlist));
    parregmatrix=zeros(b.ips,length(condlist));
for i=1:length(condlist)
    cond=condlist{i};
    binreg=zeros(b.ips,1);
    parreg=zeros(b.ips,1);
    for event = 1:size(b.eventList,1)
        movie=[cond, '_', b.eventList(event,:)];
        onset=round(b.idealOnsets(event))/TR+1;
        offset=onset+moviedur/TR;
        for x =1:length(regfile.videonames)
            if regfile.videonames(x,:)==movie
                vidindex=x;
            end
        end
        thisvidbinreg=regfile.binary_condensed(vidindex,:)';
        binreg(onset:offset-1)=thisvidbinreg;
        if length(regfile.param_condensed)>0
        thisvidparreg=regfile.param_condensed(vidindex,:)';
        parreg(onset:offset-1)=thisvidparreg;
        end
    end
    binregmatrix(:,i)=binreg;
    parregmatrix(:,i)=parreg;
    reglabels{i}=cond;
    reg_data(i).binreg=binreg; %stored redundantly as matrix and structure, but we'll use structure to extract and add to behave file
    reg_data(i).parreg=parreg;
    reg_data(i).name=cond    
    
end
save([bolddir,'/FSFuserregs.mat'], 'reglabels', 'binregmatrix','parregmatrix', 'reg_data')
end
end
end