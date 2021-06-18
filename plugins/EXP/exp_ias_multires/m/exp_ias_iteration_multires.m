%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [z,reconstruction_information] = exp_ias_iteration_multires(void)
h = waitbar(0,['IAS MAP iteration for EP.']);

n_multires = evalin('base','zef.exp_multires_n_levels');
sparsity_factor = evalin('base','zef.exp_multires_sparsity');
q = evalin('base','zef.exp_ias_multires_q');
hyper_type = evalin('base','zef.exp_ias_multires_hyper_type');
beta = evalin('base','zef.exp_ias_multires_beta');
%__ DEFINE POSSIBLE THETA SCALING __
%theta0 = sparsity_factor^((n_multires-1))*evalin('base','zef.exp_ias_multires_theta0');
theta0 = evalin('base','zef.exp_ias_multires_theta0');
%theta0_0 = theta0;
snr_val = evalin('base','zef.inv_snr');
pm_val = evalin('base','zef.inv_prior_over_measurement_db');
amplitude_db = 20; 
pm_val = pm_val - amplitude_db;
std_lhood = 10^(-snr_val/20);
number_of_frames = evalin('base','zef.number_of_frames');
source_direction_mode = evalin('base','zef.source_direction_mode');
n_decompositions = evalin('base','zef.exp_multires_n_decompositions');
weight_vec_aux = sum(sparsity_factor.^[0:n_multires-1]');
n_L1_iter = evalin('base', 'zef.inv_n_L1_iterations');
exp_ias_multires_dec =  evalin('base','zef.exp_multires_dec');
exp_ias_multires_ind =  evalin('base','zef.exp_multires_ind');
n_iter = evalin('base','zef.exp_multires_n_iter');

%Saved reconstruction information:
reconstruction_information.tag = 'EXP IAS Multiresolution';
reconstruction_information.inv_time_1 = evalin('base','zef.inv_time_1');
reconstruction_information.inv_time_2 = evalin('base','zef.inv_time_2');
reconstruction_information.inv_time_3 = evalin('base','zef.inv_time_3');
reconstruction_information.inv_sampling_frequency = evalin('base','zef.inv_sampling_frequency');
reconstruction_information.inv_high_cut_frequency = evalin('base','zef.inv_high_cut_frequency');
reconstruction_information.inv_low_cut_frequency = evalin('base','zef.inv_low_cut_frequency');
reconstruction_information.number_of_frames = evalin('base','zef.number_of_frames');
reconstruction_information.source_direction_mode = evalin('base','zef.source_direction_mode');
reconstruction_information.source_directions = evalin('base','zef.source_directions');
reconstruction_information.inv_snr = evalin('base','zef.inv_snr');
reconstruction_information.exp_ias_multires_q = q;
reconstruction_information.inv_n_L1_iterations = n_L1_iter;
reconstruction_information.exp_multires_n_iter = n_iter;

if ismember(hyper_type,[1,2])
    reconstruction_information.inv_hyperprior = evalin('base','zef.inv_hyperprior');
    reconstruction_information.pm_val = evalin('base','zef.inv_prior_over_measurement_db');
else
    reconstruction_information.exp_ias_multires_theta0 = theta0;
    reconstruction_information.exp_ias_multires_beta = beta;
end

reconstruction_information.exp_multires_n_decompositions = n_decompositions;
reconstruction_information.exp_multires_n_levels = n_multires;
reconstruction_information.exp_multires_sparsity = sparsity_factor;


[L,n_interp, procFile] = zef_processLeadfields(source_direction_mode);

if evalin('base','zef.use_gpu') == 1 && gpuDeviceCount > 0
    L = gpuArray(L);
end

if length(n_iter) < n_multires
    n_iter = n_iter(1)*ones(1,n_multires);
end

z = cell(number_of_frames,1);
f_data = zef_getFilteredData;

tic;
for f_ind = 1 : number_of_frames
    
        time_val = toc;
    if f_ind > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400)); %what does that do?
        waitbar(100,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);

    end
    
    f=zef_getTimeStep(f_data, f_ind, true);
z_vec = ones(size(L,2),1); 
theta = zeros(length(z_vec),1)+(beta+1/q-1)./theta0;


if evalin('base','zef.use_gpu') == 1 && gpuDeviceCount > 0
    f = gpuArray(f);
end
         
% inversion starts here
z_vec_aux = zeros(size(L,2),1);
theta_vec_aux = zeros(size(L,2),1);
iter_ind = 0;

for n_rep = 1 : n_decompositions

if evalin('base','zef.inv_init_guess_mode') == 2
theta =zeros(size(L,2),1)+(beta+1/q-1)./theta0;
end 

for j = 1 : n_multires

iter_ind = iter_ind + 1;    

n_mr_dec = length(exp_ias_multires_dec{n_rep}{j});

if source_direction_mode == 1 || source_direction_mode == 2
mr_dec = [exp_ias_multires_dec{n_rep}{j}; exp_ias_multires_dec{n_rep}{j}+n_interp ; exp_ias_multires_dec{n_rep}{j} + 2*n_interp];
mr_dec = mr_dec(:);
mr_ind = [exp_ias_multires_ind{n_rep}{j} ; exp_ias_multires_ind{n_rep}{j} + n_mr_dec ; exp_ias_multires_ind{n_rep}{j} + 2*n_mr_dec];
mr_ind = mr_ind(:);
%--- New Stuff ---
%mr_count =  [multires_count{n_rep}{j}; multires_count{n_rep}{j} ; multires_count{n_rep}{j}];
%mr_count = mr_count(mr_ind);
%-----------------
end

if source_direction_mode == 3 
mr_dec = exp_ias_multires_dec{n_rep}{j}; 
mr_dec = mr_dec(:);
mr_ind = exp_ias_multires_ind{n_rep}{j}; 
mr_ind = mr_ind(:);
%--- New Stuff ---
%mr_count =  multires_count{n_rep}{j}(mr_ind);
%-----------------
end

if n_iter(j) > 0
L_aux_2 = L(:,mr_dec);
theta = theta(mr_dec);
source_count = size(L_aux_2,2);
%theta0 = sparsity_factor^((n_multires-j))*theta0_0;
end

if ismember(hyper_type,[1,2])
    if evalin('base','zef.normalize_data')==1
        normalize_data = 'maximum';
    else
        normalize_data = 'average';
    end

    if hyper_type == 1
        balance_spatially = 1;
    else
        balance_spatially = 0;
    end
    if evalin('base','zef.inv_hyperprior') == 1
    [beta, theta0] = zef_find_ig_hyperprior(snr_val-pm_val,evalin('base','zef.inv_hyperprior_tail_length_db'),L_aux_2,source_count,normalize_data,balance_spatially,evalin('base','zef.inv_hyperprior_weight'));
    elseif evalin('base','zef.inv_hyperprior') == 2 
    [beta, theta0] = zef_find_g_hyperprior(snr_val-pm_val,evalin('base','zef.inv_hyperprior_tail_length_db'),L_aux_2,source_count,normalize_data,balance_spatially,evalin('base','zef.inv_hyperprior_weight'));
    end
    if q == 1
        theta0 = sqrt(theta0);
    end
end

%-----------------------------------------------------------------------------------

%__ Initialization __
n = size(L_aux_2,2);
L_aux = 1/std_lhood*L_aux_2;

if evalin('base','zef.use_gpu') == 1 && gpuDeviceCount > 0
z_vec = gather(z_vec);
end
if q == 1
    x_old = ones(n,1);
    for i = 1 : n_iter(j)
        if f_ind > 1    
        waitbar(i/n_iter(j),h,['Dec. ' int2str(n_rep) ' of ' int2str(n_decompositions) ', Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
        else
        waitbar(i/n_iter(j),h,['IAS MAP iteration. Dec. ' int2str(n_rep) ' of ' int2str(n_decompositions) ', Time step ' int2str(f_ind) ' of ' int2str(number_of_frames) '.' ]);   
        end
        z_vec = L1_optimization(L_aux_2,std_lhood,f,theta,x_old,n_L1_iter);
        theta = beta./(theta0+0.5*abs(z_vec));    
        
        x_old = z_vec;
        
    end
else
    for i = 1 : n_iter(j)
        if f_ind > 1    
        waitbar(i/n_iter(j),h,['Dec. ' int2str(n_rep) ' of ' int2str(n_decompositions) ', Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
        else
        waitbar(i/n_iter(j),h,['IAS MAP iteration. Dec. ' int2str(n_rep) ' of ' int2str(n_decompositions) ', Time step ' int2str(f_ind) ' of ' int2str(number_of_frames) '.' ]);   
        end
        w = 1./theta;
       
        z_vec = w.*(L_aux'*((L_aux*(w.*L_aux') + eye(size(L_aux,1)))\f));
       theta = (beta+1/q-1)./(theta0+0.5*abs(z_vec).^q);
    end
end

if evalin('base','zef.use_gpu') == 1 && gpuDeviceCount > 0
z_vec = gather(z_vec);
end


if n_iter(j) > 0
theta = theta(mr_ind);
z_vec = z_vec(mr_ind);
%theta = theta(mr_ind)./mr_count;
%z_vec = z_vec(mr_ind)./mr_count;
end

z_vec_aux = z_vec_aux + z_vec;
theta_vec_aux = theta_vec_aux + theta;
end
end

z{f_ind} = z_vec_aux/(n_decompositions*weight_vec_aux);
end

z = zef_postProcessInverse(z, procFile);
z = zef_normalizeInverseReconstruction(z);
close(h);