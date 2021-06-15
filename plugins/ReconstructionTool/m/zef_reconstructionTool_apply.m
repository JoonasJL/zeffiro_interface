
trueDex=cell2mat( zef.reconstructionTool.bankInfo(:,6));

zef_reconstructionTool_funtion=str2func(strcat('zef_reconstructionTool_', zef.reconstructionTool.app.FunctionDropDown.Value));

for index=1:zef.reconstructionTool.bankSize
    if trueDex(index)
        
         newRec=zef_reconstructionTool_funtion(zef.reconstructionTool.bankReconstruction{index}.reconstruction);
        
        %all functions should give out a cell!
        
        if zef.reconstructionTool.app.DeleteoriginalCheckBox.Value
          
            zef.reconstructionTool.bankReconstruction(index,1)=newRec;

            
            zef.reconstructionTool.bankInfo{index, 1}=strcat(zef.reconstructionTool.bankInfo{index, 1},'_',zef.reconstructionTool.app.FunctionDropDown.Value);
                        
            zef.reconstructionTool.bankInfobankInfo{index, 4}=size(zef.reconstructionTool.bankReconstruction(zef.reconstructionTool.bankSize).reconstruction, 1);
            zef.reconstructionTool.bankInfobankInfo{index, 5}=size(zef.reconstructionTool.bankReconstruction(zef.reconstructionTool.bankSize).reconstruction{1}, 1);

            
           
            
            
            
            
            
        else
            
            zef.reconstructionTool.bankSize=zef.reconstructionTool.bankSize+1;
            zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction=newRec;

                        
            zef.reconstructionTool.bankInfo(zef.reconstructionTool.bankSize,:)=zef.reconstructionTool.bankInfo(index,:);
            zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 1}=strcat(zef.reconstructionTool.bankInfo{index, 1},'_', zef.reconstructionTool.app.FunctionDropDown.Value);
            
            zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 4}=size(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize}.reconstruction, 1);
            zef.reconstructionTool.bankInfo{index, 5}=size(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize}.reconstruction{1}, 1);

            
            

            
        end
            
        
                
    end
    
    
    
%zef.reconstructionTool.bankInfo{index,6}=false;
end



zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;

clear index trueDex newRec nextRec








