searchQuery = "https://api.fda.gov/device/recall.json?search=event_date_posted:[2021-01-01+TO+2021-12-31]&limit=1000";
% writeOptions = weboptions('MediaType', "application/x-www-form-urlencoded", ...
%     'HeaderFields', ["PRIVATE-TOKEN" 'N1t7pbi17I8u4oDpWJlSd0qtx1xQeSwZ8rhpFk8j']);
data = webread(searchQuery);
% recalls = table;

for ii = 1:numel(data.results)
    
    recalls(ii).event_date_posted = data.results{ii}.event_date_posted;
    recalls(ii).recall_status = data.results{ii}.recall_status;
    recalls(ii).product_code = data.results{ii}.product_code;
    recalls(ii).product_description = data.results{ii}.product_description;
    recalls(ii).code_info = data.results{ii}.code_info;
    recalls(ii).recalling_firm = data.results{ii}.recalling_firm;
    recalls(ii).address_1 = data.results{ii}.address_1;
    recalls(ii).city = data.results{ii}.city;
    recalls(ii).state = data.results{ii}.state;
    recalls(ii).postal_code = data.results{ii}.postal_code;
    recalls(ii).additional_info_contact = data.results{ii}.additional_info_contact;
    recalls(ii).reason_for_recall = data.results{ii}.reason_for_recall;
    recalls(ii).root_cause_description = data.results{ii}.root_cause_description;
    recalls(ii).action = data.results{ii}.action;
    recalls(ii).product_quantity = data.results{ii}.product_quantity;
    recalls(ii).distribution_pattern = data.results{ii}.distribution_pattern;
    recalls(ii).other_submission_description = data.results{ii}.other_submission_description;
    recalls(ii).openfda = data.results{ii}.openfda;
end