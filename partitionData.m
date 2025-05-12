function data = partitionData(sub)
    
    % Create partition storage struct
    data = struct;
    
    % Define length of input struct fields
    subjectID = size(sub.subject, 2);
    num_sessions = size(sub.subject(subjectID).session, 2);
    num_recordings = size(sub.subject(subjectID).session(num_sessions).SEP.recording, 2);
    fs = sub.subject(subjectID).session(1).SEP.recording(1).headers.SampleRate;
    
    % Partition out
    for session = 1:num_sessions
        for recording = 1:num_recordings
            % Extract RS
            rest = sub.subject(subjectID).session(session).RS.recording(recording).signal;
            time_rest = size(rest, 1) / fs;
    
            % Given triggers for eyes open/close
            start_eo = find(rest(:,end) == 20);
            end_eo = find(rest(:,end) == 30);
            length_eo = length(start_eo:end_eo);
    
            start_ec = find(rest(:,end) == 40);
            end_ec = find(rest(:,end) == 50);
            length_ec = length(start_ec:end_ec);
    
            % Recommended hard-coded start and end times
            start_eo = 15*fs;
            end_eo = 73*fs;
            length_eo = length(start_eo:end_eo);
    
            start_ec = 90*fs;
            end_ec = 148*fs;
            length_ec = length(start_ec:end_ec);
    
            % Creating step for epoch shift
            num_epochs = 8; % break 64 seconds into 8 segments
            step_eo = length_eo / num_epochs;
            step_ec = length_ec / num_epochs;
            
            for epoch = 1:num_epochs
                eo = rest(start_eo:(start_eo + step_eo), :);
                data.subject(subjectID).session(session).recording(recording).RS(epoch).eo = eo;
                start_eo = start_eo + step_eo;
    
                ec = rest(start_ec:start_ec + step_ec, :);
                data.subject(subjectID).session(session).recording(recording).RS(epoch).ec = ec;
                start_ec = start_ec + step_ec;
            end
    
            sep = sub.subject(subjectID).session(session).SEP.recording(recording).signal;
            time_sep = size(sep, 1) / fs;
    
            % Epoch buffers
            t_front = round(fs * 0.1); % 512 samples/second * 0.1 seconds
            t_back = fs * 1; % 512 samples/second * 1 second
    
            % SEP - single pulse
            single = find(sep(:,end) == 101);
            single_start = single - t_front;
            single_end = single + t_back;
    
            % SEP - paired pulse
            paired = find(sep(:,end)== 201);
            paired_start = paired - t_front;
            paired_end = paired + t_back;
    
            num_pulse = length(single); % or length(paired)
    
            for pulse = 1:num_pulse
                s_pulse = sep(single_start(pulse):single_end(pulse), :);
                data.subject(subjectID).session(session).recording(recording).SEP(pulse).single = s_pulse;
    
                p_pulse = sep(paired_start(pulse):paired_end(pulse), :);
                data.subject(subjectID).session(session).recording(recording).SEP(pulse).paired = p_pulse;
            end
        end
    end
end