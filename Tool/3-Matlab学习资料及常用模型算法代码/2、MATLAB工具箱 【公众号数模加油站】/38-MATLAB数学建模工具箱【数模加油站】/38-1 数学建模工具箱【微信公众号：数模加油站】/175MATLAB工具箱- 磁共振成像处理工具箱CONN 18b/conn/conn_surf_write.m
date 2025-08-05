function a = conn_surf_write(filename,data)

dims=conn_surf_dims(8);
switch(numel(data))
    case prod(dims),    
    case 2*prod(dims),  dims=dims.*[1 1 2];
    otherwise,          error('incompatible number of vertices %d',numel(data));
end
data=reshape(data,dims);
a=struct('fname',filename,'mat',eye(4),'dim',size(data),'dt',[spm_type('float32') spm_platform('bigend')]);
a=spm_write_vol(a,data);
