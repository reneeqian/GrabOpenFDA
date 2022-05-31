function runGrabOpenFDATests()
% This runs all of the unit tests in this package and creates a TAP output
% file as well as coverage report.  It is meant to be called from a CI
% server.

%% Imports
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.TAPPlugin
import matlab.unittest.plugins.ToFile
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat
import matlab.unittest.plugins.codecoverage.CoverageReport

%% Engine
try
    % Open the Project and close when done testing
    prj = openProject(fileparts(fileparts(mfilename('fullpath'))));
    closer = onCleanup(@()close(prj));
    
    suite = TestSuite.fromProject(prj);

    runner = TestRunner.withTextOutput();

    % Files
    tapFile = fullfile(getenv('WORKSPACE'), 'testResults.tap');
    coberturaCoverageFile = fullfile(getenv('WORKSPACE'), 'coverage.xml');
    matlabCoverageFile = fullfile(getenv('WORKSPACE'), 'coverage.html');
    if exist(tapFile, 'file')
        delete(tapFile);
    end
    
    coveragefolders = fullfile(prj.RootFolder, ["Source", "Apps"]);
    runner.addPlugin(TAPPlugin.producingVersion13(ToFile(tapFile)));
    runner.addPlugin(CodeCoveragePlugin.forFolder(coveragefolders, ...
        'Producing', CoberturaFormat(coberturaCoverageFile), 'IncludingSubfolders', true));
    runner.addPlugin(CodeCoveragePlugin.forFolder(coveragefolders, ...
        'Producing', CoverageReport(matlabCoverageFile), 'IncludingSubfolders', true));
            
    % Run the tests
    results = runner.run(suite);
    display(results);
catch ME
    disp(getReport(ME, 'extended'));
    exit(1);
end
exit;
end

