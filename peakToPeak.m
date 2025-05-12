function segments = peakToPeak(segments, fs)
    % peak to peak
    
    WSize = .1; % window size in s
    Olap = 0.5; % overlap percentage
    chan = 13;  % Channel we are looking at
    WSize = floor(WSize*fs);	    % length of each data frame, 30ms
    nOlap = floor(Olap*WSize);  % overlap of successive frames, half of WSize
    hop = WSize-nOlap;	    % amount to advance for next data frame
    
    
    for sess = 1:2
        for r = 1:4
            for channel = 1:28
                for types = 1:2
                    switch types
                        case 1
                        signal = segments.subject(101).session(sess).recording(r).channel(channel).grand_avg_single;
                        case 2
                        signal = segments.subject(101).session(sess).recording(r).channel(channel).grand_avg_paired;
                    end
                    nx = length(signal);	            % length of input vector
                    len = fix((nx - (WSize-hop))/hop);	%length of output vector = total frames
    
                    % preallocate outputs for speed
                    [Pk2Pk] = deal(zeros(1,len));
    
                    for i = 1:len
                        segment = signal(((i-1)*hop+1):((i-1)*hop+WSize));
    
                        rootmean = rms(segment);
                        rootmean = sqrt(2) * 2 * rootmean;
                        Pk2Pk(i) = rootmean;
                    end
                    switch types
                        case 1
                        segments.subject(101).session(sess).recording(r).channel(channel).Pk2PkGaS = Pk2Pk; % Store feature
                        case 2
                        segments.subject(101).session(sess).recording(r).channel(channel).Pk2PkGaP = Pk2Pk; % Store feature
                    end
                    
                end
            end
        end
    end
    
    % figure
    % sig = segments.subject(101).session(2).recording(1).channel(chan).Pk2PkGaP;
    % plot((1:len)*hop/fs,sig);
    % 
    % hold on;
    % 
    % xlabel('Time (s)');
    % ylabel('Pk2Pk Feature');
    % title('Pk2Pk Feature with Stimulus');
    % stem(.1,max(sig));
end