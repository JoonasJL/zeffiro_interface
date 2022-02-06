zef_data = zef_github_updater;
zef_assign_data;
zef.h_github_updater.Name = 'ZEFFIRO Interface: GitHub updater tool';
zef.h_github_message.Value = 'Regular push.';
zef.h_github_author.Value = zef.user_tag;

zef.h_github_updater_button.ButtonPushedFcn = 'zef_githup_update_script;';


set(findobj(zef.h_github_updater.Children,'-property','FontSize'),'FontSize',zef.font_size);

set(zef.h_github_updater,'AutoResizeChildren','off');
zef.github_updater_current_size = get(zef.h_github_updater,'Position');
set(zef.h_github_updater,'SizeChangedFcn','zef.github_updater_current_size = zef_change_size_function(zef.h_github_updater,zef.github_updater_current_size);');
