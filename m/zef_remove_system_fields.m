zef.ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
zef.system_fields = zef.ini_cell(:,3);
zef.system_fields = setdiff(zef.system_fields,{'save_file','save_file_path'});
zef.system_fields = [zef.system_fields; {'compartment_activity','start_mode','colormap_cell','path_cell','use_display'}'];
for zef_i  =  1 : length(zef.system_fields)
if isfield(zef_data,zef.system_fields{zef_i});
zef_data = rmfield(zef_data,zef.system_fields{zef_i});
end
end
