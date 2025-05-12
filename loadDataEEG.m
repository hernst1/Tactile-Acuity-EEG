%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name: loadDataEEG.m
%
% Function Description: Extract the raw .gdf data files containing
% resting-state (RS) EEG recordings and sensory-evoked potential (SEP) 
% paired-pulse paradigm (PPD) (SEPPPD) EEG recordings.
% 
% Function Usage Instructions: The function is called as follows:
% >> data = loadDataEEG(subjectID, [sessionIDs]);
%
% Inputs:
%   subjectID: 3-digit integer identifying the subject
%   sessionID: vector enumerating session numbers
%
% Outputs:
%   data: struct containing EEG data organized by SEP vs RS, stored by
%   subject, session, and recording
%
% Example usage:
% >> sub1data = loadDataEEG(101, [1, 2]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = loadDataEEG(subjectID, sessionID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % setting current path to current location in directory
    currentPath = pwd;
    addpath(genpath('./Functions'))
    
    % setting struct for data storage
    data = struct;
    
    % extract number of sessions and recordings
    num_sessions = numel(sessionID);
    
    for session = 1:num_sessions
        subjectPath = fullfile(currentPath, 'NE Course Tactile Acuity Project 2024-selected');
        sessionPathRS = dir(fullfile(subjectPath, ['Subject_' num2str(subjectID) '_Session_00' num2str(sessionID(session)) '_RS']));
        sessionPathPPD = dir(fullfile(subjectPath, ['Subject_' num2str(subjectID) '_Session_00' num2str(sessionID(session)) '_SEP_PPD']));

        % List .gdf files in RS directory
        num_elements = {sessionPathRS.name};
        for i = 1:numel(num_elements)
            [~, ~, ext] = fileparts(sessionPathRS(i).name);
            if strcmpi(ext, '.gdf')
                % Extract recording ID from the filename
                recording_num = str2double(regexp(sessionPathRS(i).name, 'r(\d+)', 'tokens', 'once'));
                % Store data according to recording ID under RS
                [data.subject(subjectID).session(session).RS.recording(recording_num).signal, data.subject(subjectID).session(session).RS.recording(recording_num).headers] = sload(fullfile(sessionPathRS(i).folder, sessionPathRS(i).name));
                % Process data as needed
                disp(['Loaded ' sessionPathRS(i).name]);
            end
        end
    
        % List .gdf files in PPD directory
        num_elements = {sessionPathPPD.name};
        for i = 1:numel(num_elements)
            [~, ~, ext] = fileparts(sessionPathPPD(i).name);
            if strcmpi(ext, '.gdf')
                % Extract recording ID from the filename
                recording_num = str2double(regexp(sessionPathPPD(i).name, 'r(\d+)', 'tokens', 'once'));
                % Store data according to recording ID under SEP
                [data.subject(subjectID).session(session).SEP.recording(recording_num).signal, data.subject(subjectID).session(session).SEP.recording(recording_num).headers] = sload(fullfile(sessionPathPPD(i).folder, sessionPathPPD(i).name));
                % Process data as needed
                disp(['Loaded ' sessionPathPPD(i).name]);
            end
        end

    end
end

