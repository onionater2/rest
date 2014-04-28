function deletedumbrois(study, subjeclist, deletekey)
rootdir=['/mindhive/saxelab2/' study /']
for s =1:length(subjectlist)
    subj=subjectlist{s}
    subjROIdir=[rootdir subj '/autoROI/']
    myfiles=dir([subjROIdir '*' deletekey '*']);
    for f=1:length(myfiles)
        thisfile=myfiles(f).name
        delete([subjROIdir thisfile])
    end
end
