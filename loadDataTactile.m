%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name: loadDataTactile.m
%
% Function Description: Extract the .csv data file containing tactile acuity
% performance data.
% 
% Function Usage Instructions: The function is called as follows:
% >> data = loadDataTactile(groupID, subjectID, [sessionIDs]);
%
% Inputs:
%   groupID: 1-digit integer identifying the group number
%   subjectID: 3-digit integer identifying the subject
%   sessionID: vector enumerating session numbers
%
% Outputs:
%   data: struct containing tactile performance data and tDCS type 
%   organized by pre or post tDCS; 0 represents anode, 1 represents cathode
%
% Example usage:
% >> sub1data = loadDataEEG(1, 101, [1, 2]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = loadDataTactile(groupID, subjectID, sessionID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % setting current path to current location in directory
    currentPath = pwd;
    addpath(genpath('./Functions'))
    
    % setting struct for data storage
    data = struct;
    
    % extract number of sessions
    num_sessions = numel(sessionID);
    
    subjectPath = fullfile(currentPath, 'NE Course Tactile Acuity Project 2024-selected');
    tactileFile = fullfile(subjectPath, 'Tactile_acuity_performance.csv');
    
    % read the CSV file and change column labels
    tactileData = readtable(tactileFile);
    newColumnNames = {'Group','SubjID','SesID','condition','0.3','0.2','0.1','0','-0.1','-0.2','-0.3','-0.4','-0.5','tDCS'};
    tactileData = renamevars(tactileData, tactileData.Properties.VariableNames, newColumnNames);
    tactileData(1,:) = [];
    
    % filter data for the specified subject
    groupData = tactileData(tactileData.Group == groupID, :);
    subjectData = groupData(groupData.SubjID == subjectID, :);
    
    for session = 1:num_sessions
        % filter data for the current session
        sessionData = subjectData(subjectData.SesID == session, :);
    
        % extract pre vs post and the stimulation type
        pre_tDCS = sessionData(strcmp(sessionData.condition, 'pre-tDCS'), 5:13);
        post_tDCS = sessionData(strcmp(sessionData.condition, 'post-tDCS'), 5:13);
        catvan = sessionData.tDCS;
    
        % store the data for the current session
        data.subject(subjectID).session(session).tactile.pre_tDCS_acc = pre_tDCS;
        data.subject(subjectID).session(session).tactile.post_tDCS_acc = post_tDCS;
        data.subject(subjectID).session(session).tactile.type = catvan;
    end
end


