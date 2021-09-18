



dbFieldNames=fieldnames(zef.dataBank.tree.(zef.dataBank.hash).data);


for dbi=1:length(dbFieldNames)
     if strcmp(zef.dataBank.tree.(zef.dataBank.hash).type, 'gmm')
    
          zef.GMM.model = zef.dataBank.tree.(zef.dataBank.hash).data.model; 
            zef.GMM.dipoles = zef.dataBank.tree.(zef.dataBank.hash).data.dipoles;
            zef.GMM.parameters = zef.dataBank.tree.(zef.dataBank.hash).data.parameters; 
            zef.GMM.time_variables = [];
            zef.GMM.amplitudes = zef.dataBank.tree.(zef.dataBank.hash).data.amplitudes;

        
                zef_GMM_update;

        
        
     else
    
    if ~(startsWith(dbFieldNames{dbi}, 'Properties')||startsWith(dbFieldNames{dbi}, 'type')) %prevents the copy of the properties if the data is an matObject
        zef.(dbFieldNames{dbi})=zef.dataBank.tree.(zef.dataBank.hash).data.(dbFieldNames{dbi});
    end
    
     end
    
end

if zef.dataBank.loadParents
    
        zef.dataBank.hash=reverse(zef.dataBank.hash);
        zef.dataBank.hash=extractAfter(zef.dataBank.hash, '_');
        zef.dataBank.hash=reverse(zef.dataBank.hash);

        if ~strcmp(zef.dataBank.hash, 'node') 
            zef_dataBank_setData;
        end        
    
end

    
           








