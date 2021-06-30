%This is script for opening advanced GMM plot options.
zef_plotopt_start_boolean = true;

if isfield(zef.GMM.apps,'PlotOpt')
    if isvalid(zef.GMM.apps.PlotOpt)
        zef.GMM.apps.PlotOpt.UIFigure.Visible='off';
        zef.GMM.apps.PlotOpt.UIFigure.Visible='on';
        zef_plotopt_start_boolean = false;
    end
end

if zef_plotopt_start_boolean
zef.GMM.apps.PlotOpt = GMM_PlotOpt;

%Set position besides GMM app
zef.GMM.apps.PlotOpt.UIFigure.Position(2) = zef.GMM.apps.main.UIFigure.Position(2);
zef_temp_screen_size = get(0, 'ScreenSize');
if zef.GMM.apps.main.UIFigure.Position(3)+zef.GMM.apps.PlotOpt.UIFigure.Position(3)+zef.GMM.apps.main.UIFigure.Position(1)>zef_temp_screen_size(3)
    zef.GMM.apps.PlotOpt.UIFigure.Position(1) = zef.GMM.apps.main.UIFigure.Position(1)-zef.GMM.apps.PlotOpt.UIFigure.Position(3);
else
    zef.GMM.apps.PlotOpt.UIFigure.Position(1) = zef.GMM.apps.main.UIFigure.Position(1)+zef.GMM.apps.main.UIFigure.Position(3);
end  

zef_update_GMMPlotOpts;

%set parameters if saved in ZI: 
%(Naming concept: zef.GMM.apps.main."field" = zef."field")
zef_props = properties(zef.GMM.apps.PlotOpt);
zef_n = 18;
for zef_i = 2:length(zef_props)
    if strcmp(zef.GMM.apps.PlotOpt.(zef_props{zef_i-1}).Type,'uilabel')
        zef_n=zef_n+1;
        zef.GMM.parameters(zef_n,1)={zef.GMM.apps.PlotOpt.(zef_props{zef_i-1}).Text};
        if ~strcmp(zef_props{zef_i},'GMM_colors')
            zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value=zef.GMM.parameters{zef_n,2}{1};
        else
            if iscell(zef.GMM.parameters{zef_n,2}{1})
                zef_aux_str = '';
                for zef_k = 1:length(zef.GMM.parameters{zef_n,2}{1})
                    zef_aux_str = [zef_aux_str,zef.GMM.parameters{zef_n,2}{1}{zef_k},', '];
                end
                zef_aux_str = zef_aux_str(1:end-2);
                zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value=zef_aux_str;
                clear zef_k zef_aux_str
            else
                zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value=zef.GMM.parameters{zef_n,2}{1};
            end
        end 
        if isfield(zef,zef_props{zef_i})
            if ~ischar(zef.(zef_props{zef_i})) && ~strcmp(zef_props{zef_i},'GMM_colors')
            zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value = num2str(zef.(zef_props{zef_i}));
            elseif strcmp(zef_props{zef_i},'GMM_colors') && ~isempty(zef.GMM_colors)
                if isempty(zef.GMM_colors)
                   zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value = ''; 
                else
                zef_aux_mat = reshape(zef.GMM_colors',[],1)';
                zef_aux_str = ['[',num2str(zef_aux_mat(1))];
                for zef_j = 2:length(zef_aux_mat)
                    if mod(zef_j,3)==0
                        zef_aux_str = [zef_aux_str,' ',num2str(zef_aux_mat(zef_j)),'],'];
                    elseif mod(zef_j,3)==1
                        zef_aux_str = [zef_aux_str,' [',num2str(zef_aux_mat(zef_j))];
                    else
                        zef_aux_str = [zef_aux_str,' ',num2str(zef_aux_mat(zef_j))];
                    end
                end 
                zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value = zef_aux_str(1:end-1);
                clear zef_aux_str zef_aux_mat
                end
            elseif isempty(zef.(zef_props{zef_i}))
                zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value = '';
            else
            	zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value = zef.(zef_props{zef_i});
            end
            %zef = rmfield(zef,zef_props{zef_i});
            zef.GMM.parameters{zef_n,2} = {zef.GMM.apps.PlotOpt.(zef_props{zef_i}).Value};
        end
    end
end
clear zef_props zef_i zef_j zef_n zef_temp_screen_size

if strcmp(zef.GMM.apps.PlotOpt.GMM_comp_ord.Value,'3')
    zef.GMM.apps.PlotOpt.GMM_dip_comp.Enable = 'on'; 
    zef.GMM.apps.PlotOpt.GMM_ellip_comp.Enable = 'on';
else
    zef.GMM.apps.PlotOpt.GMM_dip_comp.Enable = 'off'; 
    zef.GMM.apps.PlotOpt.GMM_ellip_comp.Enable = 'off';
end

if strcmp(zef.GMM.apps.PlotOpt.GMM_ellip_coloring.Value,'2')
    zef.GMM.apps.PlotOpt.GMM_colors.Enable = 'on';
else
    zef.GMM.apps.PlotOpt.GMM_colors.Enable = 'off';
end

zef.GMM.apps.PlotOpt.GMM_comp_ord.ValueChangedFcn = 'zef.GMM.parameters{19,2} = {zef.GMM.apps.PlotOpt.GMM_comp_ord.Value}; if strcmp(zef.GMM.parameters{19,2},''3''); zef.GMM.apps.PlotOpt.GMM_dip_comp.Enable = ''on''; zef.GMM.apps.PlotOpt.GMM_ellip_comp.Enable = ''on''; else zef.GMM.apps.PlotOpt.GMM_dip_comp.Enable = ''off''; zef.GMM.apps.PlotOpt.GMM_ellip_comp.Enable = ''off''; end;';
zef.GMM.apps.PlotOpt.GMM_dip_comp.ValueChangedFcn = 'zef.GMM.parameters{22,2} = {zef.GMM.apps.PlotOpt.GMM_dip_comp.Value};';
zef.GMM.apps.PlotOpt.GMM_ellip_comp.ValueChangedFcn = 'zef.GMM.parameters{23,2} = {zef.GMM.apps.PlotOpt.GMM_ellip_comp.Value};';
zef.GMM.apps.PlotOpt.GMM_dip_num.ValueChangedFcn = 'zef.GMM.parameters{20,2} = {zef.GMM.apps.PlotOpt.GMM_dip_num.Value};';
zef.GMM.apps.PlotOpt.GMM_ellip_num.ValueChangedFcn = 'zef.GMM.parameters{21,2} = {zef.GMM.apps.PlotOpt.GMM_ellip_num.Value};';
zef.GMM.apps.PlotOpt.GMM_ellip_coloring.ValueChangedFcn = 'zef.GMM.parameters{24,2} = {zef.GMM.apps.PlotOpt.GMM_ellip_coloring.Value}; if strcmp(zef.GMM.parameters{24,2},''2''); zef.GMM.apps.PlotOpt.GMM_colors.Enable = ''on''; else zef.GMM.apps.PlotOpt.GMM_colors.Enable = ''off''; end;';
zef.GMM.apps.PlotOpt.GMM_colors.ValueChangedFcn = 'if isempty(str2num(zef.GMM.apps.PlotOpt.GMM_colors.Value)); zef.GMM.parameters{25,2} = {strsplit(erase(zef.GMM.apps.PlotOpt.GMM_colors.Value,{'''''''','' ''}),{'','','';''})}; else zef.GMM.parameters{25,2} = {zef.GMM.apps.PlotOpt.GMM_colors.Value}; end;';
zef.GMM.apps.PlotOpt.UIFigure.CloseRequestFcn = 'delete(zef.GMM.apps.PlotOpt);';

%set fonts
set(findobj(zef.GMM.apps.PlotOpt.UIFigure.Children,'-property','FontSize'),'FontSize',zef.font_size);

end
clear zef_plotopt_start_boolean
