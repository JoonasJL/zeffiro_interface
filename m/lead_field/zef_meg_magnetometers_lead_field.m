warning('off');
zef.lead_field_type = 2;
if zef.downsample_surfaces == 1;
    zef_downsample_surfaces;
end;
zef.source_interpolation_on = 1;
set(zef.h_source_interpolation_on,'value',1);
zef = zef_postprocess_fem_mesh(zef);
zef.n_sources_mod = 1;
zef.source_ind = [];
zef_update_fig_details;
zef = zef_process_meshes(zef);
zef_attach_sensors_volume(zef,zef.sensors);
zef = zef_lead_field_matrix(zef);
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
