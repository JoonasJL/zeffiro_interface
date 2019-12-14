%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
zef_data = zeffiro_interface_lf_bank_tool; 
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end        
clear zef_i zef_data;
set(zef.h_lf_bank_tool,'Name','ZEFFIRO Interface: Multi lead field tool');
set(findobj(zef.h_lf_bank_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_lf_bank_tool.Children,'-property','FontSize'),'FontSize',9);
zef.h_lf_item_list.ValueChangedFcn = 'zef.lf_item_selected = get(zef.h_lf_item_list,''value'');';
zef.h_add_lf_item.ButtonPushedFcn = '[zef.yesno] = questdlg(''Add current lead field?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_add_lf_item; end;';
zef.h_lf_tag.ValueChangedFcn = 'zef.lf_tag = get(zef.h_lf_tag, ''Value'');';
zef.h_merge_lead_fields.ButtonPushedFcn = '[zef.yesno] = questdlg(''Merge selected lead fields?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_combine_lead_fields; end;';
zef.h_delete_selected.ButtonPushedFcn = '[zef.yesno] = questdlg(''Delete selected lead field items?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_delete_lf_item; end;';
zef.h_lf_normalization.ValueChangedFcn = 'zef.lf_normalization = find(ismember(get(zef.h_lf_normalization,''items''),get(zef.h_lf_normalization,''value'')));';
zef.h_lf_bank_compute_lead_fields.ButtonPushedFcn = '[zef.yesno] = questdlg(''Re-calculate the lead field matrices for the selected items?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_lf_bank_compute_lead_fields; end;';
zef.h_lf_bank_update_measurements.ButtonPushedFcn = '[zef.yesno] = questdlg(''Substitute the measurement data of the selected lead field items with the current measurement dataset?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_lf_bank_update_measurements; end;';
zef.h_lf_bank_make_all.ButtonPushedFcn = '[zef.yesno] = questdlg(''Create a mesh and calculate the lead field matrices for the selected items?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef.source_interpolation_on = 1; set(zef.h_source_interpolation_on,''value'',1); [zef.sensors,zef.reuna_p,zef.reuna_t] = process_meshes([]); [zef.nodes,zef.nodes_b,zef.tetra,zef.sigma_ind,zef.surface_triangles]=fem_mesh([]);zef.tetra_aux = zef.tetra; [zef.sigma,zef.brain_ind,zef.non_source_ind,zef.nodes,zef.tetra,zef.sigma_prisms,zef.prisms,zef.submesh_ind]=zef_sigma([]); zef.n_sources_mod = 1; zef.source_ind = []; set(zef.h_text_elements,''string'',num2str(size(zef.tetra,1)+size(zef.prisms,1))); set(zef.h_text_nodes,''string'',num2str(size(zef.nodes,1)));zef_lf_bank_compute_lead_fields; end;';
zef_init_lf_bank_tool;
