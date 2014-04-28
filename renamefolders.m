function renamefolders(subjectlist, rootdir, subdir, key, suffix)
%eg renamefolders(makeIDs('FSF', [1:19]), '/mindhive/saxelab2/FSF/', '/results/', 'results', 'old')
suffixatend=1;
deleteold=1; %1for move isntead of copy
numsubj=length(subjectlist);
for i=1:numsubj
    subject=subjectlist{i}
    try
    thisdir=[rootdir,subject,subdir]
    files=dir(thisdir)
    for f=3:length(files) %skip . and ..
        file=files(f).name
        if suffixatend
            newfile=[thisdir,'FSF_main_with_art_reg_results_normed_mushedparam_mesoph']
            %newfile=[thisdir,file,'_',suffix]
            file=[thisdir,file]
        else
            newfile=[thisdir,suffix,'_',file]
            file=[thisdir,file]
        end
        if ~strcmp(key, '')
            %check=findstr(key,file);
            %if ~isempty(check)
            check=strcmp([thisdir, key],file)
            if check==1
            if deleteold
            movefile(file,newfile)
            else
            copyfile(file,newfile)
            end
            end
        else
            if deleteold
            movefile(file,newfile)
            else
            copyfile(file,newfile)
            end
        end
    end
    catch
        string=['failure for subject ', subject]
    end
end
end