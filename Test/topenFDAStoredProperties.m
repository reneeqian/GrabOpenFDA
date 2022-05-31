classdef topenFDAStoredProperties < matlab.unittest.TestCase
% Test stored properties    
    
    methods (TestMethodSetup)
        % All tests start blank
        function RemoveProps(testCase)
            % AccessToken
            if ispref('openFDA', 'AccessToken')
                at = getpref('openFDA', 'AccessToken');
                testCase.addTeardown(@()setpref('openFDA', 'AccessToken', at));
                rmpref('openFDA', 'AccessToken');
            else
%                 testCase.addTeardown(@()rmpref('openFDA', 'AccessToken'));
            end
            
        end
        
    end
 
    methods(Test)
        
        % Test no access token
        function shouldErrorWithNoAccessToken(testCase)
            g = openFDA;
            testCase.verifyError(@()g.AccessToken, 'openFDA:NoToken');
        end
        
        % Removal of access token
        function shouldReturnProvidedAccessToken(testCase)
            g = openFDA('AccessToken', "Hello World");
            testCase.verifyEqual(g.AccessToken, "Hell*******");
        end
        
        % Store and clear token
        function shouldStoreAndClearToken(testCase)
            openFDA.storeAccessToken("HurrayBeer")
            g = openFDA();
            testCase.verifyEqual(g.AccessToken, "Hurr******");
            g.clearAccessToken()
            testCase.verifyError(@()g.AccessToken, 'openFDA:NoToken');
        end
            
        % Access Token Predence
        function shouldTakeProvidedAccessTokenOverStored(testCase)
            openFDA.storeAccessToken("HelloWorld")        
            g = openFDA('AccessToken', "HurrayBeer");            
            testCase.verifyEqual(g.AccessToken, "Hurr******");
        end                        
        
        % Bad Token
        function shouldNotAcceptBadToken(testCase)
            g = openFDA;
            testCase.verifyError(@()g.storeAccessToken("foo"), 'openFDA:InvalidToken');
            testCase.verifyError(@()openFDA('AccessToken', "foo"), 'openFDA:InvalidToken');
        end
        
        % Test setter for AccessToken
        function shouldSetNewToken(testCase)
            g = openFDA;
            g.AccessToken = "Hello World";
            testCase.verifyMatches(g.AccessToken, "Hell*******")            
        end        
        
    end
 
end