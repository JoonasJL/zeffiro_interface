zef.h_plugin = fopen('zeffiro_plugins.ini');
zef.ini_cell = textscan(zef.h_plugin,'%s','HeaderLines',17,'Delimiter',',');
for i = 1 : length(zef.ini_cell{:})/3
zef.h_menu = findobj(zef.h_zeffiro_window_main,'Tag',zef.ini_cell{1}{3*i-1});
zef.h_menu = uimenu(zef.h_menu,'label',zef.ini_cell{1}{3*i-2},'callback',zef.ini_cell{1}{3*i});
end
zef = rmfield(zef,'ini_cell');
zef = rmfield(zef,'h_plugin');
zef = rmfield(zef,'h_menu');