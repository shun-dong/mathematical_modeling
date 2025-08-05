function fileout=conn_surf_curv2nii(filein)
% conn_surf_curv2nii converts freesurfer paint files to surface nifti file
%
% conn_surf_curv2nii(filename)
%     filename : input lh curvature file (containing fsaverage nvertices voxels; see help conn_freesurfer_read_curv)
%
% e.g. conn_surf_curv2nii('lh.curv')
%      creates curv.surf.nii surface nifti file
%

fileout={};
[filepath,filename,fileext]=fileparts(filein);
assert(~isempty(regexp(filename,'^lh\.')),'input filename must be of the form lh.*');
a1=conn_freesurfer_read_curv(filein);
a2=conn_freesurfer_read_curv(fullfile(filepath,[regexprep(filename,'^lh\.','rh.'),fileext]));

fileout=fullfile(filepath,[regexprep(filename,'^lh\.',''),fileext,'.surf.nii']);
conn_surf_write(fileout,[a1(:),a2(:)]);
