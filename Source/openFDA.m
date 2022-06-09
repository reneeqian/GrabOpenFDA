classdef openFDA < handle
    % openFDA - Class for interacting with openFDA API.

    % Hidden and protected
    properties (Access = protected, Hidden)
        PrivateAccessToken % Actual access token
        ProvidedAccessToken string = "" % Access token provided by constructor
    end

    % Dependent properties
    properties (Dependent)
        AccessToken string % Visible Access Token
    end

    % Public Methods, Setters, Getters
    methods

        % Constructor
        function obj = openFDA(options)
            % api = openFDA('Parameter', value, ...)
            %
            % Input Parameter/Value Pairs
            %
            % AccessToken: Access Token provided by openFDA.
            %              See MakeAnAccessToken.mlx to learn how to get a
            %              token.
            %              String scalar or character row vector.
            %              Default is the token stored on disk by:
            %              openFDA.storeAccessToken.
            %              If none is provided, an error will occur.
            %

            arguments
                options.AccessToken(1, 1) string {mustBeToken(options.AccessToken)} = ""
            end

            if logical(strlength(options.AccessToken))
                obj.ProvidedAccessToken = options.AccessToken;
            end

        end

        % Get Issues
        function deviceRecalls = getDeviceRecalls(obj,year)
            % get openFDA issues
            %
            % Inputs:
            %   openFDA Object
            %   year
            %
            % Outputs:
            %   deviceRecalls - Struct containing Issue info

            arguments
                obj
                year(1, 1) double {mustBePositive, mustBeInteger, mustBeGreaterThan(year,1700)}
            end
            %             writeOptions = weboptions('MediaType', "application/x-www-form-urlencoded", ...
            %                 'HeaderFields', ["PRIVATE-TOKEN" obj.PrivateAccessToken]);
            data = webread("https://api.fda.gov/device/recall.json?search=event_date_posted:[" + year + "-01-01+TO+" + year + "-12-31]&limit=1000");

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

            if ~nargout
                clearvars deviceRecalls
            end
        end


        % Setters and getters
        % get.AccessToken
        function token = get.AccessToken(obj)
            % token = get.AccessToken(obj)
            token = obj.PrivateAccessToken;
            token = pad(extractBefore(token, 5), strlength(token), "right", "*");
        end

        % get.PrivateAccessToken
        function pat = get.PrivateAccessToken(obj)
            % privatetoken = get.PrivateAccessToken(obj)
            if logical(strlength(obj.ProvidedAccessToken))
                % Provided one
                pat = obj.ProvidedAccessToken;
            elseif ispref('openFDA', 'AccessToken')
                % Grab from disk if not provided
                pat = convertCharsToStrings(getpref('openFDA', 'AccessToken'));
            else
                % None, error
                throwAsCaller(MException('openFDA:NoToken', 'An Access Token is required.\nSet it using openFDA.storeAccessToken\nor by providing it to the constructor.'));
            end
        end

        % set.AccessToken
        function set.AccessToken(obj, newtoken)
            % Access token is provided
            obj.ProvidedAccessToken = newtoken;
        end

    end

    % Static methods
    methods (Static)

        % Store the access token
        function storeAccessToken(newtoken)
            % storeAccessToken(newtoken)
            %
            % Stores an access token that persists across MATLAB sessions.  If
            % any token already exists, it overwrites the existing access token
            % with a new one.
            %
            % Example:
            %   >>openFDA.storeAccessToken('HelloWorld')
            %
            % See Also: clearAccessToken

            arguments
                newtoken(1, 1) string {mustBeToken(newtoken)}
            end
            setpref('openFDA', 'AccessToken', newtoken);

        end

        % Clear the access token
        function clearAccessToken()
            % clearAccessToken - Clears any existing access tokens
            %
            % Example:
            %   >>openFDA.clearAccessToken()
            %
            % See Also: storeAccessToken

            % Remove pref
            if ispref('openFDA', 'AccessToken')
                rmpref('openFDA', 'AccessToken');
            end

        end

    end

end

% Validators
function mustBeToken(token)
% mustBeToken(token)

% Try to validate it (more than five or zero length)
if strlength(token) < 5 && logical(strlength(token))
    throwAsCaller(MException('openFDA:InvalidToken', 'Token must be more than 5 characters'));
end

end
