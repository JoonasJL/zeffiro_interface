function [GMModel,GMModelDipoles] = zef_GMModeling
h = waitbar(0,['Gaussian mixature model.']);

%Options 
options = statset('MaxIter',str2num(evalin('base','zef.GMM.parameters.Values{2}')));
if strcmp(evalin('base','zef.GMM.parameters.Values{3}'),'1')
    Sigma = 'full';
else
    Sigma = 'diagonal';
end

if strcmp(evalin('base','zef.GMM.parameters.Values{4}'),'1')
    SharedCovariance = false;
else
    SharedCovariance = true;
end

%Initialization
K = str2num(evalin('base','zef.GMM.parameters.Values{1}'));
if size(K,1) > size(K,2)
    K=K';
end

z_vec = evalin('base','zef.reconstruction');
if isempty(z_vec)
    warning('There is no reconstruction.')
end

source_positions = evalin('base','zef.source_positions');
threshold = str2num(evalin('base','zef.GMM.parameters.Values{5}'));
reg_value = str2num(evalin('base','zef.GMM.parameters.Values{15}'));

if iscell(z_vec)
    T=str2num(evalin('base','zef.GMM.parameters.Values{18}'));
    t_start = str2num(evalin('base','zef.GMM.parameters.Values{17}'));
    GMModel=cell(T,1);
    GMModelDipoles=cell(T,1);
else
    t_start=1;
    T=1;
end

if length(K) < T
    K = [K,K(end)*ones(1,T-length(K))];
end

waitbar(0,h,['Step 1 of ',num2str(T),'. Please wait.']);
tic;
for t=t_start:T
    best_BIC = Inf;
    if T > 1
        time_val = toc;
    end
    for k = 1:K(t)
    if T == 1
        time_val = toc;
    end
    if t > 1
        date_str = ['Ready: ',datestr(datevec(now+(T/(t-1) - 1)*time_val/86400)),'.'];
    elseif k > 1 && T == 1
        date_str = ['Ready: ',datestr(datevec(now+(K(t)/(k-1) - 1)*time_val/86400)),'.'];
    else
        date_str = [];
    end
    %calculuate squares of current densities
    if iscell(z_vec)
        z=sqrt(z_vec{t}(1:3:end).^2+z_vec{t}(2:3:end).^2+z_vec{t}(3:3:end).^2);
        direct = [z_vec{t}(1:3:end),z_vec{t}(2:3:end),z_vec{t}(3:3:end)];
        direct = direct./sqrt(sum(direct.^2,2));
    else
        z=sqrt(z_vec(1:3:end).^2+z_vec(2:3:end).^2+z_vec(3:3:end).^2);
        direct = [z_vec(1:3:end),z_vec(2:3:end),z_vec(3:3:end)];
        direct = direct./sqrt(sum(direct.^2,2));
    end
    J = sqrt(z);      %current density
    z = z./max(z);
    %Maximally expected sampling step:
    ind = z<threshold;
    z(ind) = 0;
    normalization_const = 16*size(source_positions,1)/sum(z);
    z = round(normalization_const*z);
    z(z(~ind)==0)=1;
    ind = z > 0;
    z_cum = cumsum(z(ind));
    ind2 = zeros(1,z_cum(end));
    ind2(z_cum-z(ind)+1)=1;
    activity_pos = source_positions(ind,:);
    activity_dir = direct(ind,:);
    
    activity_space = [activity_pos(cumsum(ind2),:),activity_dir(cumsum(ind2),:)];    
    %calculate Gaussian mixature models:
    try
        GMModel_aux = fitgmdist(activity_space,k,'CovarianceType',Sigma, ...
            'SharedCovariance',SharedCovariance,'Options',options);
    catch
        GMModel_aux = fitgmdist(activity_space,k,'CovarianceType',Sigma, ...
            'SharedCovariance',SharedCovariance,'RegularizationValue',reg_value,'Options',options);
    end
    
    if GMModel_aux.BIC < best_BIC
            best_BIC = GMModel_aux.BIC;
        if T>1
            GMModel{t} = GMModel_aux;
        else
            GMModel = GMModel_aux;
        end
    end
    
    if T==1
      waitbar(k/K(t),h,['Step ',num2str(k),' of ',num2str(K(t)),'. ',date_str]);
    end
    
    end     %end of k loop
    
    if T > 1
        ind2 = [];
        for k = 1:size(GMModel{t}.mu,1)
            [~,ind2(k)] = min(sum((GMModel{t}.mu(k,1:3)-source_positions).^2,2));
        end
        disp(['Relative centroid current densities at the frame ',num2str(t),': ',num2str(J(ind2)'/max(J))])
        GMModelDipoles{t} = J(ind2).*GMModel{t}.mu(:,4:6);
        waitbar((t-t_start+1)/(T-t_start+1),h,['Frame ',num2str(t),' of ',num2str(T),'. ',date_str]);
    else
       ind2 = [];
        for k = 1:size(GMModel.mu,1)
            [~,ind2(k)] = min(sum((GMModel.mu(k,1:3)-source_positions).^2,2));
        end
        disp(['Relative centroid current densities: ',num2str(J(ind2)'/max(J))]) 
        GMModelDipoles = J(ind2).*GMModel.mu(:,4:6);
    end

end     %end of t loop

close(h);
end
    