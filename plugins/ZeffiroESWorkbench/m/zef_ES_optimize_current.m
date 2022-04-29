function [y_ES, ES_optimized_current_density, residual, flag_val, source_magnitude, source_position_index, source_directions] = zef_ES_optimize_current(varargin)
%% varargin
if nargin >= 2
    [alpha, TolFun] = deal(varargin{1:2});
    if nargin == 3
        active_electrodes = varargin{3};
    else
        active_electrodes = evalin('base','zef.ES_active_electrodes');
    end
end
%% Source properties
L_aux                       = evalin('base','zef.L');
L_aux = L_aux';
source_positions            = evalin('base','zef.inv_synth_source(:,1:3)');
source_directions           = evalin('base','zef.inv_synth_source(:,4:6)');
relative_source_amplitude   = evalin('base','zef.ES_relative_source_amplitude');
source_position_index       = zeros(size(source_positions,1),1);

for i = 1:size(source_positions,1)
    [~,aux_index] = min(sqrt(sum((evalin('base','zef.source_positions') - source_positions(i,:)).^2,2)));
    source_position_index(i) = aux_index;
end

source_directions           = source_directions./sqrt(sum(source_directions.^2,2));
L_ES_projection             = zeros(length(source_position_index),size(L_aux,2));
x_ES_projection             = zeros(length(source_position_index),1);
J_x_ES = [];

for running_index = 1:length(source_position_index)
    J_x_ES = [J_x_ES ; [3*(source_position_index(running_index)-1)+1:3*source_position_index(running_index)]'];  %#ok<NBRAK,AGROW>
    for ell_ind = 1:3
        L_ES_projection(running_index,:) = L_ES_projection(running_index,:) + L_aux(3*(source_position_index(running_index)-1)+ell_ind,:).*source_directions(running_index,ell_ind);
    end
    x_ES_projection(running_index) = relative_source_amplitude.*evalin('base',['zef.inv_synth_source(' num2str(running_index) ',7)']).*evalin('base','zef.ES_source_density')./evalin('base','zef.ES_cortex_thickness');
end

source_magnitude        = x_ES_projection;
singular_value_mean = mean(svd(L_aux));
alpha = singular_value_mean*alpha;

J_x_ES                  = setdiff((1:size(L_aux,1))',J_x_ES);
%% Active Electrodes and L_ES_projection
if evalin('base','zef.ES_search_method') == 1
    L_ES_projection   = [L_aux(J_x_ES,:)  ; L_ES_projection];
else
    k_val = TolFun*max(source_magnitude)/singular_value_mean;
    L_ES_projection   = [k_val*L_aux(J_x_ES,:)  ; L_ES_projection];
end
x_ES_projection   = [zeros(length(J_x_ES),1) ; x_ES_projection];

if not(isempty(active_electrodes))
    L_ES_projection   = L_ES_projection(:,active_electrodes);
else
    active_electrodes = 1:size(L_ES_projection,2);
    L_ES_projection   = L_ES_projection(:,active_electrodes);
end

M_mat = eye(size(L_ES_projection,2)) - ones(size(L_ES_projection,2))/size(L_ES_projection,2);
L_ES_projection = L_ES_projection*M_mat;



%% Search
switch evalin('base','zef.ES_search_method')
    case 1
        %% LP setup
        opts = optimset('linprog');
        if isfloat(TolFun)
            TolFun = round(TolFun,10);
        end
        opts.TolFun     = 1E-10;            %TolFun;
        opts.Algorithm  = 'dual-simplex';
        opts.Display    = 'off';
        lower_bound     = -Inf;
        upper_bound     =  Inf;
        if lower_bound == 0
            lower_bound = -Inf;
        end
        if upper_bound == 0
            upper_bound = Inf;
        end
        if length(lower_bound) <= 1
            lower_bound = lower_bound*ones(size(L_ES_projection,2),1);
        end
        if length(upper_bound) <= 1
            upper_bound = upper_bound*ones(size(L_ES_projection,2),1);
        end
        positivity_constraint   = evalin('base','zef.ES_positivity_constraint');
        negativity_constraint   = evalin('base','zef.ES_negativity_constraint');
        if not(isempty(positivity_constraint))
            p_c_ind = sub2ind([length(positivity_constraint) size(L_ES_projection,2)],[1:length(positivity_constraint)]',positivity_constraint(:)); %#ok<NBRAK>
            p_c_aux = zeros(length(positivity_constraint),size(L_ES_projection,2));
            p_c_aux(p_c_ind) = -1;
            L_ES_projection = [L_ES_projection; p_c_aux];
            x_ES_projection = [x_ES_projection ; zeros(length(positivity_constraint),1)];
        end
        if not(isempty(negativity_constraint))
            n_c_ind = sub2ind([length(negativity_constraint) size(L_ES_projection,2)],[1:length(negativity_constraint)]',negativity_constraint(:)); %#ok<NBRAK>
            n_c_aux = zeros(length(negativity_constraint),size(L_ES_projection,2));
            n_c_aux(n_c_ind) = 1;
            L_ES_projection = [L_ES_projection; n_c_aux];
            x_ES_projection = [x_ES_projection ; zeros(length(negativity_constraint),1)];
        end
        %% Linprog Solver
%         if alpha <= 0
%             [y_ES,~,flag_val] = linprog(sum(L_ES_projection)', -L_ES_projection, -x_ES_projection, [], [], lower_bound, upper_bound, opts);
%         else
%             L_ES_projection = [L_ES_projection ; alpha*ones(1,size(L_ES_projection,2))];
%             x_ES_projection = [x_ES_projection; 0];
%             [y_ES,~,flag_val] = linprog(sum(L_ES_projection)'+alpha, -L_ES_projection, -x_ES_projection, [], [], lower_bound, upper_bound, opts);
%         end
        %% Linprog Solver (20/4/2022)
        if alpha <= 0
            g = [sum(L_ES_projection)' ; sum(L_ES_projection)' ];
            
            if zef.h_ES_CVXCheckBox.Value
                % CVX
                [y_ES,~,flag_val] = zef_cvx_linprog(g, ...
                    [-L_ES_projection zeros(size(L_ES_projection)); zeros(size(L_ES_projection)) L_ES_projection; -sum(L_ES_projection) -sum(L_ES_projection) ], ...
                    [-x_ES_projection; x_ES_projection; 0], ...
                    [], ...
                    [], ...
                    [lower_bound; lower_bound], ...
                    [upper_bound; upper_bound], ...
                    [],opts);
            else
                % Mat
                [y_ES,~,flag_val] = linprog(g, ...
                    [-L_ES_projection zeros(size(L_ES_projection)); zeros(size(L_ES_projection)) L_ES_projection;-sum(L_ES_projection) -sum(L_ES_projection) ], ...
                    [-x_ES_projection; x_ES_projection; 0], ...
                    [], ...
                    [], ...
                    [lower_bound; lower_bound], ...
                    [upper_bound; upper_bound], ...
                    opts);
            end
            
            if ismember(flag_val,[1 3])
                y_ES = (reshape(y_ES,size(L_ES_projection,2),2));
                y_ES(:,2) = - y_ES(:,2);
                y_ES = sum(y_ES,2);
            else
                y_ES = zeros(size(L_ES_projection,2),1);
            end
                            
        else
            L_ES_projection = [L_ES_projection; alpha*eye(size(L_ES_projection,2))];
            x_ES_projection = [x_ES_projection; zeros(size(L_ES_projection,2),1)];
            
            g = [zeros(size(L_ES_projection,2),1); ones(size(L_ES_projection,1),1) ];
            
            if evalin('base','zef.h_ES_CVXCheckBox.Value')
                [y_ES,~,flag_val] = zef_cvx_linprog(g, ...
                    [-L_ES_projection -eye(size(L_ES_projection,1))  ; L_ES_projection -eye(size(L_ES_projection,1)) ], ...
                    [-x_ES_projection ; x_ES_projection], ...
                    [], ...
                    [], ...
                    [-evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1); TolFun*max(source_magnitude)*max(source_magnitude)*ones(size(L_ES_projection,1)-size(L_ES_projection,2),1); zeros(size(L_ES_projection,2),1) ], ...
                    [ evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1); max(source_magnitude)*ones(size(L_ES_projection,1)-size(L_ES_projection,2),1); evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1) ],...
                    opts);
            else
                [y_ES,~,flag_val] = linprog(g, ...
                    [-L_ES_projection -eye(size(L_ES_projection,1))  ; L_ES_projection -eye(size(L_ES_projection,1)) ], ...
                    [-x_ES_projection ; x_ES_projection], ...
                    [], ...
                    [], ...
                    [-evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1); TolFun*max(source_magnitude)*ones(size(L_ES_projection,1)-size(L_ES_projection,2),1); zeros(size(L_ES_projection,2),1) ], ...
                    [ evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1); max(source_magnitude)*ones(size(L_ES_projection,1)-size(L_ES_projection,2),1); evalin('base','zef.ES_max_current_channel')*ones(size(L_ES_projection,2),1) ],...
                    opts);
            end
            
            y_ES = y_ES(1:size(L_ES_projection,2));
            
%             if flag_val == 1
%                 y_ES = (reshape(y_ES,size(L_ES_projection,2),4));
%                 y_ES(:,[2 4]) = - y_ES(:,[2 4]);
%                 y_ES = sum(y_ES,2);
%             else
%                 y_ES = zeros(size(L_ES_projection,2),1);
%             end
            
        end
    case 2
        delta = evalin('base','zef.ES_delta');
        if evalin('base','zef.ES_L1_iter') >= 2
                    y_ES = ones(size(L_ES_projection,2),1);
        for inv_iter = 1:evalin('base','zef.ES_L1_iter')
            
            d_sqrt = abs(y_ES)+delta;
            L_ES_projection_aux = L_ES_projection.*repmat(d_sqrt',size(L_ES_projection,1),1);
    
            
            if evalin('base','zef.h_ES_CVXCheckBox.Value')
            L_ES_projection_aux = [L_ES_projection_aux; alpha*eye(size(L_ES_projection,2))];
            x_ES_projection_aux = [x_ES_projection_aux; zeros(size(L_ES_projection,2),1)];
                y_ES = zef_cvx_ls(L_ES_projection_aux, x_ES_projection_aux);
                y_ES = d_sqrt.*y_ES;
            else
                y_ES = ((L_ES_projection_aux)' * (L_ES_projection_aux) + alpha^2*eye(size(L_ES_projection_aux,2))) \ (L_ES_projection_aux)'*x_ES_projection;
                y_ES = d_sqrt.*y_ES;
            end
        end
        else 
             if evalin('base','zef.h_ES_CVXCheckBox.Value')
                   L_ES_projection = [L_ES_projection; alpha*eye(size(L_ES_projection,2))];
            x_ES_projection = [x_ES_projection; zeros(size(L_ES_projection,2),1)];
              y_ES = zef_cvx_ls(L_ES_projection, x_ES_projection);
            else
                y_ES = ((L_ES_projection)' * (L_ES_projection) + alpha^2*eye(size(L_ES_projection,2))) \ L_ES_projection'*x_ES_projection;
             end
        end
        flag_val = 1;
        
    case 3
        active_electrodes       = zef_ES_4x1_sensors;
        alpha_coeff             = x_ES_projection/(L_ES_projection(1) -sum(L_ES_projection(2:5)));
        y_ES                    = zeros(size(L_aux,2),1);
        y_ES(active_electrodes) = [alpha_coeff; -alpha_coeff/4*ones(4,1) ];
        flag_val                = 1;
end
%% Postprocess
y_ES = M_mat*y_ES;





[~, y_ES] = zef_ES_rwnnz(y_ES, evalin('base','zef.ES_relative_weight_nnz'), evalin('base','zef.ES_score_dose'));
%y_ES = y_ES - mean(y_ES);
y_idx = y_ES ~= 0;
y_ES(y_idx) = y_ES(y_idx)-mean(y_ES(y_idx));

 y_ES = evalin('base','zef.ES_total_max_current') * y_ES ./ sum(abs(y_ES));
if max(abs(y_ES))      >= evalin('base', 'zef.ES_max_current_channel')
   y_ES = evalin('base','zef.ES_max_current_channel') * y_ES ./ max(abs(y_ES));
end

% try
%     max_val = max(abs(y_ES));
%     sum_val = sum(abs(y_ES));
%     y_ES = y_ES.*min(evalin('base', 'zef.ES_max_current_channel')./max_val, evalin('base','zef.ES_total_max_current')./sum_val);
% catch
%     warning('could not do this')
% end

if not(isempty(active_electrodes))
    y_ES_aux = zeros(size(L_aux,2),1);
    if evalin('base','zef.ES_search_method') ~= 3
        y_ES_aux(active_electrodes) = y_ES;
    else
        y_ES_aux(active_electrodes) = y_ES(active_electrodes);
    end
    y_ES = y_ES_aux;
end
%% Flag value from LP solver
if ismember(flag_val,[1 3])
        ES_optimized_current_density  = reshape(L_aux*y_ES,3,size(L_aux,1)/3);
    if evalin('base','zef.ES_search_method') ~= 3
        if not(isempty(active_electrodes))
            residual = norm(L_ES_projection*y_ES(active_electrodes)-x_ES_projection,1);
        else
            residual = norm(L_ES_projection*y_ES-x_ES_projection,1);
        end
    else
        y_ES = zeros(size(L_aux,2),1);
        ES_optimized_current_density  = reshape(L_aux*y_ES,3,size(L_aux,1)/3);
        residual = 0;
    end
else
    y_ES = zeros(size(L_aux,2),1);
    ES_optimized_current_density = zeros(size(L_aux,2),1);
    residual = 0;
end
