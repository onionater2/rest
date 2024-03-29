function reslice_anats(dim)
%createdby AES 4/30/13 downsample anat rois to dimensions of functionals
    rootdir='/mindhive/saxelab2/EIB/checkingrois/'
    cd(rootdir)
    %files=dir('*.img')
    files=dir('*peelen*.img')
    numfiles=length(files);
    
    masks=0;
    for x=1:numfiles
       image=files(x).name
       volume=spm_vol(image);
       volume.dim
       
       if sum(volume.dim==dim)<3
           masks=masks+1;
           masksToReslice{masks}=image;
       end
    end
    
    masksToReslice
    numMasks=length(masksToReslice);
    target='/mindhive/saxelab/roi_library/functional/EIBrois/ROI_lSTS_kanparcel_xyz.img'; %anything with SPM ready dimensions
    target_vol=spm_vol(target)
    if target_vol.dim~=dim
        disp ('target image dimensions do not match dimensions specified in function call')
    else
        for m=1:numMasks
        input_mask=masksToReslice{m}
        input_vol=spm_vol([rootdir input_mask])
        input_descrip=input_vol.descrip;
        p={target;[rootdir input_mask]};
        %[outputmat, header]=simple_reslice(target, input_mask);
        spm_reslice_amy(p); %ghettohack solution = create own spm_reslice and change hardcoded flags. but this should be callable with diff flags?
%         output_vol=spm_vol([rootdir input_mask])
%         output_vol.descrip=input_descrip;
%         outputmat(outputmat>0)=1;
%         outputmat(outputmat<=0)=0;
%         target_vol.fname    = [rootdir 'ROI_resliced_' input_name(5:end) ]
%         target_vol.descrip=input_desc;
%         writtenVol=spm_write_vol(target_vol, outputmat)
        end
    end
end
