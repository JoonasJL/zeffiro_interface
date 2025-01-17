%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
if  ismac
zef.h_ias_map_estimation = open('ramus_sampler.fig');
elseif ispc
zef.h_ias_map_estimation = open('ramus_sampler.fig');
else
zef.h_ias_map_estimation = open('ramus_sampler.fig');
end
set(zef.h_ias_map_estimation,'Name','ZEFFIRO Interface: Metropolized RAMUS Sampler');
set(findobj(zef.h_ias_map_estimation.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_ias_map_estimation.Children,'-property','FontSize'),'FontSize',zef.font_size);
zef_init_ramus_sampler;
if isfield(zef,'measurements')
if iscell(zef.measurements)
    set(zef.h_inv_data_segment,'enable','on');
end
if not(iscell(zef.measurements))
    set(zef.h_inv_data_segment,'enable','off');
end
end
uistack(flipud([zef.h_inv_multires_n_levels; zef.h_inv_multires_sparsity; zef.h_inv_hyperprior ; zef.h_inv_beta ; zef.h_inv_theta0;
    zef.h_inv_likelihood_std ; zef.h_inv_n_sampler; zef.h_inv_n_burn_in; zef.h_inv_multires_n_iter ;
    zef.h_inv_sampling_frequency ; zef.h_inv_low_cut_frequency ;
    zef.h_inv_high_cut_frequency ; zef.h_inv_time_1 ; zef.h_inv_time_2; zef.h_number_of_frames; zef.h_inv_time_3; zef.h_inv_data_segment ; zef.h_inv_cancel ;
    zef.h_inv_apply; zef.h_inv_start  ]),'top');
