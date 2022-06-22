load data/ary_model/ary_model.mat;

load zeffiro_projects/pallomalli_pem.mat;
[L_eeg] = zef_lead_field_eeg_multilayer_sphere( ...
    zef_data.sensors_attached_volume(:,1:3)/1000, ...
    zef_data.source_positions/1000, ...
    [], ...
    ary_model ...
);
L_eeg = -L_eeg - mean(-L_eeg,1);
zef_data.L = zef_data.L - mean(zef_data.L,1);
rdm_v_1 = sqrt(sum((zef_data.L./repmat(sqrt(sum(zef_data.L.^2)),size(zef_data.L,1),1) - L_eeg./repmat(sqrt(sum(L_eeg.^2)),size(L_eeg,1),1)).^2))';
mag_v_1 = 1 - sqrt(sum(zef_data.L.^2))'./sqrt(sum(L_eeg.^2))';
s_p_1 = zef_data.source_positions;

load zeffiro_projects/pallomalli_pem.mat;
[L_eeg] = zef_lead_field_eeg_multilayer_sphere( ...
    zef_data.sensors_attached_volume(:,1:3)/1000, ...
    zef_data.source_positions/1000, ...
    [], ...
    ary_model ...
);
L_eeg = -L_eeg - mean(-L_eeg,1);
zef_data.L = zef_data.L - mean(zef_data.L,1);
rdm_v_2 = sqrt(sum((zef_data.L./repmat(sqrt(sum(zef_data.L.^2)),size(zef_data.L,1),1) - L_eeg./repmat(sqrt(sum(L_eeg.^2)),size(L_eeg,1),1)).^2))';
mag_v_2 = 1 - sqrt(sum(zef_data.L.^2))'./sqrt(sum(L_eeg.^2))';
s_p_2 = zef_data.source_positions;

load zeffiro_projects/pallomalli_pem.mat;
[L_eeg] = zef_lead_field_eeg_multilayer_sphere( ...
    zef_data.sensors_attached_volume(:,1:3)/1000, ...
    zef_data.source_positions/1000, ...
    [], ...
    ary_model ...
);
L_eeg = -L_eeg - mean(-L_eeg,1);
zef_data.L = zef_data.L - mean(zef_data.L,1);
rdm_v_3 = sqrt(sum((zef_data.L./repmat(sqrt(sum(zef_data.L.^2)),size(zef_data.L,1),1) - L_eeg./repmat(sqrt(sum(L_eeg.^2)),size(L_eeg,1),1)).^2))';
mag_v_3 = 1 - sqrt(sum(zef_data.L.^2))'./sqrt(sum(L_eeg.^2))';
s_p_3 = zef_data.source_positions;

load zeffiro_projects/pallomalli_pem.mat;
[L_eeg] = zef_lead_field_eeg_multilayer_sphere( ...
    zef_data.sensors_attached_volume(:,1:3)/1000, ...
    zef_data.source_positions/1000, ...
    [], ...
    ary_model ...
);
L_eeg = -L_eeg - mean(-L_eeg,1);
zef_data.L = zef_data.L - mean(zef_data.L,1);
rdm_v_4 = sqrt(sum((zef_data.L./repmat(sqrt(sum(zef_data.L.^2)),size(zef_data.L,1),1) - L_eeg./repmat(sqrt(sum(L_eeg.^2)),size(L_eeg,1),1)).^2))';
mag_v_4 = 1 - sqrt(sum(zef_data.L.^2))'./sqrt(sum(L_eeg.^2))';
s_p_4 = zef_data.source_positions;
