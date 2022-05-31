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
         
        % Get number of projects and URLs to them.
        P = getProjects(obj, options);
           
        % Submodule digraph
        dg = submoduleGraph(obj, options)
        
        % Set all projects to internal visibility
        internalizeProjects(obj, options)        
        
        % Download a file
        filecontents = downloadFile(obj, projectID, filename, options)
        
        % Get topics for each project
        topics = getTopics(obj, projectIDs)

        % Get User info based on user ID
        userinfo = getUser(obj, userid)
        
        % Create Issue
        Issue = createIssue(obj, ProjectID, IssueTitle, IssueBody, options)
        
        % Edit Issue
        Issue = editIssue(obj, ProjectID, IssueID, options)
        
        % Add comment to issue
        IssueComment = newIssueComment(obj, ProjectID, IssueID, CommentBody)
        
        % Get Issues
        function Issues = getIssues(obj,ProjectID)
            % get openFDA issues
            %
            % Inputs:
            %   openFDA Object
            %   Project ID
            %
            % Outputs:
            %   Issue - Struct containing Issue info
            
            arguments
                obj
                ProjectID(1, 1) double {mustBePositive, mustBeInteger}
            end
            writeOptions = weboptions('MediaType', "application/x-www-form-urlencoded", ...
                'HeaderFields', ["PRIVATE-TOKEN" obj.PrivateAccessToken]);
            Issues = webread("https://insidelabs-git.mathworks.com/api/v4/projects/" + ProjectID + "/issues?",...
                writeOptions);
            
            if ~nargout
                clearvars Issues
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
