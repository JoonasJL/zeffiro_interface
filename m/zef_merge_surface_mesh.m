function zef_merge_surface_mesh(compartment_tag,triangles,points,varargin)

if not(isempty(varargin))
merge = varargin{1};
else
merge = evalin('base',['zef.' compartment_tag '_merge']);
end

triangles_0 = evalin('base',['zef.' compartment_tag '_triangles']);
points_0 = evalin('base',['zef.' compartment_tag '_points']);
submesh_ind_0 = evalin('base',['zef.' compartment_tag '_submesh_ind']);

if merge

[points,~,ind_aux] = unique([points_0 ; points],'rows');   
triangles = ind_aux([triangles_0; triangles + size(points_0,1)]); 
submesh_ind = [submesh_ind_0 size(triangles,1)];    

else
    
    submesh_ind = [size(triangles,1)];  
    
end

eval(['zef_data.' compartment_tag '_points = points;']);
eval(['zef_data.' compartment_tag '_triangles = triangles;']);
eval(['zef_data.' compartment_tag '_submesh_ind = submesh_ind;']);
assignin('base','zef_data',zef_data);
evalin('base','zef_assign_data;');

end
