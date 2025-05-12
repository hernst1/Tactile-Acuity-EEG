function sscCount = calculateSSC(signal)
    % Calculate the slope sign changes in a signal
    diffs = diff(signal);
    sscCount = sum((diffs(1:end-1) .* diffs(2:end)) < 0);
end
