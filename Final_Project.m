%{ 
Project III, Group 1
Subjects 101, 102, 103

Use sload() to load .gdf files

Right median nerve and S1 primary somatosensory cortex - channels C3/C4

Exclude M1, M2, T7, T8 datapoints but not triggers in last column

Hypothesis:
Transcranial electrical stimulation applied over the primary somatosensory
cortex will enhance tactile perception, as measured by performance in a 
tactile orientation discrimination task. A single session of transcranial 
direct current stimulation in conjunction with a single session of 
transcranial pulsed current stimulation is hypothesized to result in 
immediate and enduring improvements in tactile perception compared to 
baseline performance. Additionally, alterations in resting-state 
electroencephalogram signals are anticipated, reflecting changes in 
connectivity patterns, particularly evidenced by changes in the 
sensory-evoked potential paired-pulse depression paradigm.

Resulting steps of analysis:

Behavioral Analysis
- subject-based, run-wise (row) paired t-test between performance in days
vs conditions (pre/post tDCS)


%}
%% since original/intended hypothesis compares anodal to cathodal
% should we also include that analysis in our work, or not because our
% hypothesis did not differentiate between the two
% should we only analyze based on our hypothesis, not based on the
% recommendations from the intended hypothesis

%% Loading data

sub1EEG = loadDataEEG(101, [1, 2]);
sub1Tactile = loadDataTactile(1, 101, [1, 2]);

%{
data = struct;
data.sub.sess.tac
data.sub.sess.rec

rec.sep.signal
rec.sep.trigger_marker
rec.rest
rec.rest.trigger_marker

tact.pre.row_acc_data
tact.post.row_acc_data
tact.type.cath_or_an
%}

%% Behavioral Analysis


%% Neurophysiological Analysis


%% Machine Learning

