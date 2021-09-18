function zef_set_sliders_print(mode,h_axes_image)

if mode == 1

h_axes_image.Colormap = zef_colormap(evalin('base','zef.h_update_colormap.Value'));
zef_update_ambience(h_axes_image);
zef_update_diffusion(h_axes_image);
zef_update_specular(h_axes_image);
if evalin('base','zef.update_brightness'); 
zef_update_brightness(h_axes_image); 
end;
if evalin('base','zef.update_contrast'); 
zef_update_contrast(h_axes_image); 
end;
if evalin('base','zef.update_transparency_reconstruction'); 
zef_update_transparency_reconstruction(h_axes_image,0,evalin('base','zef.update_transparency_reconstruction')); 
end;
if evalin('base','zef.update_transparency_surface'); 
zef_update_transparency_surface(h_axes_image,0,evalin('base','zef.update_transparency_surface')); 
end;
if evalin('base','zef.update_transparency_sensor'); 
zef_update_transparency_sensor(h_axes_image,0,evalin('base','zef.update_transparency_sensor')); 
end;
if evalin('base','zef.update_transparency_additional'); 
zef_update_transparency_additional(h_axes_image,0,evalin('base','zef.update_transparency_additional')); 
end;
if evalin('base','zef.update_transparency_cones');
 zef_update_transparency_cones(h_axes_image,0,evalin('base','zef.update_transparency_cones')); 
end
if not(isequal(evalin('base','zef.update_zoom'),evalin('base','zef.cam_va'))); 
zef_update_zoom(h_axes_image); 
end;
if abs(evalin('base','zef.colorscale_min_slider')); 
zef_update_colorscale_min(h_axes_image,0,evalin('base','zef.colorscale_min_slider')); 
end;
if abs(evalin('base','zef.colorscale_max_slider')); 
zef_update_colorscale_max(h_axes_image,0,evalin('base','zef.colorscale_max_slider')); 
end;
zef_set_lights(evalin('base','zef.update_lights'),h_axes_image);

elseif mode == 2 

if evalin('base','zef.brain_transparency') < 1 || evalin('base','zef.use_parcellation')
if evalin('base','zef.update_transparency_reconstruction');
zef_update_transparency_reconstruction(h_axes_image,0,evalin('base','zef.update_transparency_reconstruction')); 
end;
end

end
end
