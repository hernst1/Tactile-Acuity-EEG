function [svmModel, knnModel, lrModel, presvmAccuracies, preknnAccuracies, prelrAccuracies, postsvmAccuracies, postknnAccuracies, postlrAccuracies, AUC, sepoch_rej_ratio, pepoch_rej_ratio] = trainAndTestClassifier(data, sessionID, channels, fs)
    % Initialize feature and label arrays
    features = [];
    labels = [];
    postfeatures = [];
    postlabels = [];

    % Specify subject
    subjectID = length(data.subject);
    sempty_count = 0;
    pempty_count = 0;
    stotal_count = 0;
    ptotal_count = 0;

    % Iterate over channel
    for channel = channels
        try
            for types = 1:2  % 1 for single, 2 for paired
                switch types
                    case 1
                        if (isempty(data.subject(subjectID).session(1).recording(1).channel(channel).grand_avg_single) || isempty(data.subject(subjectID).session(1).recording(2).channel(channel).grand_avg_single) || isempty(data.subject(subjectID).session(2).recording(1).channel(channel).grand_avg_single) || isempty(data.subject(subjectID).session(2).recording(2).channel(channel).grand_avg_single))
                            sempty_count = sempty_count + 1;
                            continue
                        else
                            signal = [(data.subject(subjectID).session(1).recording(1).channel(channel).grand_avg_single + data.subject(subjectID).session(1).recording(2).channel(channel).grand_avg_single)/2, (data.subject(subjectID).session(2).recording(1).channel(channel).grand_avg_single + data.subject(subjectID).session(2).recording(2).channel(channel).grand_avg_single)/2];
                            data = peakToPeak(data, fs);
                            pk2pkFeature = [(data.subject(subjectID).session(1).recording(1).channel(channel).Pk2PkGaS + data.subject(subjectID).session(1).recording(2).channel(channel).Pk2PkGaS)/2, (data.subject(subjectID).session(2).recording(1).channel(channel).Pk2PkGaS + data.subject(subjectID).session(2).recording(2).channel(channel).Pk2PkGaS)/2];
                        end
                        stotal_count = stotal_count + 1;
                    case 2
                        if (isempty(data.subject(subjectID).session(1).recording(1).channel(channel).grand_avg_paired) || isempty(data.subject(subjectID).session(1).recording(2).channel(channel).grand_avg_paired) || isempty(data.subject(subjectID).session(2).recording(1).channel(channel).grand_avg_paired) || isempty(data.subject(subjectID).session(2).recording(2).channel(channel).grand_avg_paired))
                            pempty_count = pempty_count + 1;
                            continue
                        else
                            signal = [(data.subject(subjectID).session(1).recording(1).channel(channel).grand_avg_paired + data.subject(subjectID).session(1).recording(2).channel(channel).grand_avg_paired)/2, (data.subject(subjectID).session(2).recording(1).channel(channel).grand_avg_paired + data.subject(subjectID).session(2).recording(2).channel(channel).grand_avg_paired)/2];
                            data = peakToPeak(data, fs);
                            pk2pkFeature = [(data.subject(subjectID).session(1).recording(1).channel(channel).Pk2PkGaP + data.subject(subjectID).session(1).recording(2).channel(channel).Pk2PkGaP)/2, (data.subject(subjectID).session(2).recording(1).channel(channel).Pk2PkGaP + data.subject(subjectID).session(2).recording(2).channel(channel).Pk2PkGaP)/2];
                        end
                        ptotal_count = ptotal_count + 1;
                end
    
                %Calculate Slope Sign Change
                sscFeature = calculateSSC(signal);
    
                % Mean Absolute Value (MAV)
                mavFeature = mean(abs(signal));
    
                % Power Spectral Density (PSD)
                [psdFeature, ~] = pwelch(signal, [], [], [], fs);
                psdFeature = mean(psdFeature);
    
                % Average Pk2Pk across the specified channels
                avgPk2Pk = mean([mean(pk2pkFeature)]);
    
                % Concatenate all features
                features = [features; [mavFeature, avgPk2Pk, psdFeature, sscFeature]];
                labels = [labels; types-1]; % 0 for single, 1 for paired pulses
            end

            for types = 1:2  % 1 for single, 2 for paired
                switch types
                    case 1
                        if (isempty(data.subject(subjectID).session(sessionID).recording(3).channel(channel).grand_avg_single) || isempty(data.subject(subjectID).session(sessionID).recording(4).channel(channel).grand_avg_single))
                            %sempty_count = sempty_count + 1;
                            continue
                        else
                            signal = [data.subject(subjectID).session(sessionID).recording(3).channel(channel).grand_avg_single, data.subject(subjectID).session(sessionID).recording(4).channel(channel).grand_avg_single];
                            data = peakToPeak(data, fs);
                            pk2pkFeature = [data.subject(subjectID).session(sessionID).recording(3).channel(channel).Pk2PkGaS, data.subject(subjectID).session(sessionID).recording(4).channel(channel).Pk2PkGaS];
                        end
                        %stotal_count = stotal_count + 1;
                    case 2
                        if (isempty(data.subject(subjectID).session(sessionID).recording(3).channel(channel).grand_avg_paired) || isempty(data.subject(subjectID).session(sessionID).recording(4).channel(channel).grand_avg_paired))
                            pempty_count = pempty_count + 1;
                            continue
                        else
                            signal = [data.subject(subjectID).session(sessionID).recording(3).channel(channel).grand_avg_paired, data.subject(subjectID).session(sessionID).recording(4).channel(channel).grand_avg_paired];
                            data = peakToPeak(data, fs);
                            pk2pkFeature = [data.subject(subjectID).session(sessionID).recording(3).channel(channel).Pk2PkGaP, data.subject(subjectID).session(sessionID).recording(4).channel(channel).Pk2PkGaP];
                        end
                        %ptotal_count = ptotal_count + 1;
                end

                %Calculate Slope Sign Change
                sscFeature = calculateSSC(signal);
    
                % Mean Absolute Value (MAV)
                mavFeature = mean(abs(signal));
    
                % Power Spectral Density (PSD)
                [psdFeature, ~] = pwelch(signal, [], [], [], fs);
                psdFeature = mean(psdFeature);
    
                % Average Pk2Pk across the specified channels
                avgPk2Pk = mean([mean(pk2pkFeature)]);
    
                % Concatenate all features
                postfeatures = [postfeatures; [mavFeature, avgPk2Pk, psdFeature, sscFeature]];
                postlabels = [postlabels; types-1]; % 0 for single, 1 for paired pulses
            end
        catch ME
        warning('Failed to process subject %d, session %d: %s', subjectID, sessionID, ME.message);
        end
    end

    disp(size(features))
    % Feature Selection using mRMR
    [rankedFeatures, scores] = fscmrmr(features, labels);
    disp(['Feature: ' num2str(size(rankedFeatures)) ' , Score: ' num2str(scores)])
    rankFeat = features(:,rankedFeatures);
    rankFeatpost = postfeatures(:,rankedFeatures);
    % Prepare data splits using 5-fold cross-validation
    cv = cvpartition(length(labels), 'KFold', 5);

    % Initialize accuracy storage
    presvmAccuracies = zeros(cv.NumTestSets, 1);
    preknnAccuracies = zeros(cv.NumTestSets, 1);
    prelrAccuracies = zeros(cv.NumTestSets, 1);
    postsvmAccuracies = zeros(cv.NumTestSets, 1);
    postknnAccuracies = zeros(cv.NumTestSets, 1);
    postlrAccuracies = zeros(cv.NumTestSets, 1);

    AUCSsvm = 0;
    AUCSknn = 0;
    AUCSlr = 0;

    % Train and test each model across folds
    for i = 1:cv.NumTestSets
        trainIdx = cv.training(i);
        testIdx = cv.test(i);

        pretrainData = rankFeat(trainIdx, :);
        pretrainLabels = labels(trainIdx);
        pretestData = rankFeat(testIdx, :);
        pretestLabels = labels(testIdx);

        posttestData = rankFeatpost(testIdx, :);
        posttestLabels = postlabels(testIdx);

        % SVM model
        svmModel = fitcsvm(pretrainData, pretrainLabels, 'KernelFunction', 'linear', 'BoxConstraint', 1);
        predictions = predict(svmModel, pretestData);
        presvmAccuracies(i) = sum(predictions == pretestLabels) / numel(pretestLabels);
        postdictions = predict(svmModel, posttestData);
        [~, ~, ~, AUCsvm] = perfcurve(posttestLabels, postdictions, 1);
        AUCSsvm = AUCSsvm + AUCsvm;
        postsvmAccuracies(i) = sum(postdictions == posttestLabels) / numel(posttestLabels);

        % KNN model
        knnModel = fitcknn(pretrainData, pretrainLabels, 'NumNeighbors', 5);
        predictions = predict(knnModel, pretestData);
        preknnAccuracies(i) = sum(predictions == pretestLabels) / numel(pretestLabels);
        postdictions = predict(knnModel, posttestData);
        [~, ~, ~, AUCknn] = perfcurve(posttestLabels, postdictions, 1);
        AUCSknn = AUCSknn + AUCknn;
        postknnAccuracies(i) = sum(postdictions == posttestLabels) / numel(posttestLabels);

        % Linear Regression model
        lrModel = fitlm(pretrainData, pretrainLabels);
        predictions = predict(lrModel, pretestData);
        prelrAccuracies(i) = 1 - mean((predictions - pretestLabels).^2); % R-squared as a form of accuracy
        postdictions = predict(lrModel, posttestData);
        [~, ~, ~, AUClr] = perfcurve(posttestLabels, postdictions, 1);
        AUCSlr = AUCSlr + AUClr;
        postlrAccuracies(i) = 1 - mean((postdictions - posttestLabels).^2); % R-squared as a form of accuracy
    end
    AUCSsvm = AUCSsvm / cv.NumTestSets;
    AUCSknn = AUCSknn / cv.NumTestSets;
    AUCSlr = AUCSlr / cv.NumTestSets;

    AUC = [AUCSsvm,AUCSknn,AUCSlr];

    % % Calculate max accuracies
    % svmAccuracymax = max(presvmAccuracies);
    % knnAccuracymax = max(knnAccuracies);
    % lrAccuracymax = max(lrAccuracies);
    %disp(['SVM Max ' num2str(svmAccuracymax) ' KNN Max ' num2str(knnAccuracymax) ' LR Max ' num2str(lrAccuracymax)])

    % Calculate average accuracies
    presvmAccuracy = mean(presvmAccuracies);
    preknnAccuracy = mean(preknnAccuracies);
    prelrAccuracy = mean(prelrAccuracies);
    postsvmAccuracy = mean(postsvmAccuracies);
    postknnAccuracy = mean(postknnAccuracies);
    postlrAccuracy = mean(postlrAccuracies);

    sepoch_rej_ratio = sempty_count / stotal_count;
    pepoch_rej_ratio = pempty_count / ptotal_count;

end

