warning('off');
zef.lead_field_type = 3; 
if zef.downsample_surfaces == 1; 
    zef_downsample_surfaces; 
end; 
zef.source_interpolation_on = 1; 
set(zef.h_source_interpolation_on,'value',1); 
zef_postprocess_fem_mesh;  
zef.n_sources_mod = 1; 
zef.source_ind = []; 
zef_update_fig_details;
zef_process_meshes; 
zef_attach_sensors_volume(zef.sensors);
lead_field_matrix;
warning('on');