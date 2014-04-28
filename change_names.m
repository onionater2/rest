function change_names(study, subjects, resultname, appendname)

%% rename results directories so you can rerun analyses without losing existing

rootdir=['/mindhive/saxelab2/' study '/']; 
cd(rootdir);
s=size(subjects);
numSubj=s(2);
for subj=1:numSubj
    thisSubj=subjects{subj}
    subjdir=[rootdir thisSubj '/'];
    cd(subjdir)
	d=dir;
	s=size(d);
	numDirs=s(1);
	for i=1:numDirs
         if strcmp(d(i).name, resultname)
	cd(d(i).name)
        old=pwd;
        newname=[old '_' appendname];
	cd(subjdir)
	movefile(old,newname);
end
end

end
end
