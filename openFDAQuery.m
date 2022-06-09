searchQuery = "https://api.fda.gov/device/recall.json?search=event_date_posted:[2021-01-01+TO+2021-12-31]&limit=1000";
% writeOptions = weboptions('MediaType', "application/x-www-form-urlencoded", ...
%     'HeaderFields', ["PRIVATE-TOKEN" 'N1t7pbi17I8u4oDpWJlSd0qtx1xQeSwZ8rhpFk8j']);
data = webread(searchQuery);
% recalls = table;

for ii = 1:numel(data.results)
    recalls(ii).event_date_posted = datetime(data.results{ii}.event_date_posted);
    recalls(ii).recall_status = data.results{ii}.recall_status;

    if isfield(data.results{ii},'product_code')
        recalls(ii).product_code = data.results{ii}.product_code;
    else
        recalls(ii).product_code = '';
    end

    recalls(ii).product_description = data.results{ii}.product_description;

    if isfield(data.results{ii},'code_info')
        recalls(ii).code_info = data.results{ii}.code_info;
    else
        recalls(ii).code_info = '';
    end
    if isfield(data.results{ii},'recalling_firm')
        recalls(ii).recalling_firm = data.results{ii}.recalling_firm;
    else
        recalls(ii).recalling_firm = '';
    end

    %     recalls(ii).additional_info_contact = data.results{ii}.additional_info_contact;
    recalls(ii).reason_for_recall = data.results{ii}.reason_for_recall;
    recalls(ii).root_cause_description = data.results{ii}.root_cause_description;

    if isfield(data.results{ii},'action')
        recalls(ii).action = data.results{ii}.action;
    else
        recalls(ii).action = '';
    end
    %     recalls(ii).product_quantity = data.results{ii}.product_quantity;
    %     recalls(ii).distribution_pattern = data.results{ii}.distribution_pattern;
    %     recalls(ii).other_submission_description = data.results{ii}.other_submission_description;
    if isfield(data.results{ii}.openfda,'device_class') && ~isstrprop(data.results{ii}.openfda.device_class,'alpha')
        recalls(ii).DeviceClass = str2num(data.results{ii}.openfda.device_class);
        recalls(ii).MedicalSpecialtyDescription = data.results{ii}.openfda.medical_specialty_description;
    else
        recalls(ii).DeviceClass = nan;
        recalls(ii).MedicalSpecialtyDescription = '';
    end
end

recallTable = struct2table(recalls);
%%
deviceRecalls = recallTable(~isnan(recallTable.DeviceClass),:);