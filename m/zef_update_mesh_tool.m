%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface

if zef.mlapp == 1 
    zef.mesh_smoothing_on = zef.h_checkbox_mesh_smoothing_on.Value;
zef.refinement_on = zef.h_refinement_on.Value;
zef.source_interpolation_on = zef.h_source_interpolation_on.Value;
zef.downsample_surfaces = zef.h_downsample_surfaces.Value;
zef.imaging_method = zef.h_popupmenu1.Value;
zef.location_unit = zef.h_popupmenu6.Value;
zef.source_direction_mode = zef.h_popupmenu2.Value;
zef.mesh_resolution = (zef.h_edit65.Value);
zef.meshing_accuracy = (zef.h_edit_meshing_accuracy.Value);
zef.smoothing_strength = (zef.h_smoothing_strength.Value);
zef.solver_tolerance = (zef.h_edit76.Value);
zef.n_sources = (zef.h_edit75.Value);
zef.max_surface_face_count = zef.h_max_surface_face_count.Value ;
else

if zef.cp_on
zef.enable_str = 'on';    
else
zef.enable_str = 'off';   
end;

set(zef.h_edit_cp_a, 'enable', zef.enable_str);
set(zef.h_edit_cp_b, 'enable', zef.enable_str);
set(zef.h_edit_cp_c, 'enable', zef.enable_str);
set(zef.h_edit_cp_d, 'enable', zef.enable_str);

set(zef.h_popupmenu1,'value',zef.imaging_method);

end