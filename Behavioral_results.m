% ------------------------------------------------------------------------
% Behavioral data analysis for the manuscript "Overlapping and unique
% neural circuits supports perceptual decision making and confidence".
%
% Written by Jiwon Yeon, last edited Oct.08.18
% ------------------------------------------------------------------------

clear all

motherPath = pwd;
dataPath = [pwd '/Data/'];

Subjects = 1:25;

%% Organize data

for sub = Subjects;
    subName = ['Sub' num2str(sub)];
    Runs = dir([dataPath subName '_*.mat']);    
    
    info = [];  % trial information across runs
    resp = [];  % responses across runs
    
    for run = 1:length(Runs)               
        load([dataPath Runs(run).name])     % load data
        Blocks = length(p.answers);     % number of blocks in a run
                
        dec_rt = []; conf_rt = [];  % response times for decision and confidence        
        dec_cr = [];    % corret or incorrect decision
        conf_resp = [];     % confidence response
        
        for block = 1:Blocks
            dec_rt = [dec_rt; p.response_time{block}(:,1)];
            dec_cr = [dec_cr; p.answers{block}(:,3)];
            conf_rt = [conf_rt; p.response_time{block}(:,2)];
            conf_resp = [conf_resp; p.answers{block}(:,2)];
        end
        resp = [resp; [dec_rt, conf_rt, dec_cr, conf_resp]];    % save block data
        nTrials = length(dec_rt);   % number of completed trials 
        
        trial_type = p.trial_type(1:nTrials)'; %1-decision+confidence; 2-decision; 3-catch (invalid cue)
        
        coherence = p.percentCoherentMovement(1:nTrials)'; %1: low, 2: high
        
        idx = (trial_type == 1);    % find trials have confidence response
        conf_cue = zeros(nTrials,1);
        conf_cue(idx,1) = p.conf_type(1:sum(idx))'+1; %0: no confidence response; 2-4: 2-4-point scale
                
        info = [info; [trial_type, coherence, conf_cue]];   % save trial information
    end
    
    % Rescaling confidence response
    conf_original = resp(:,4);
    scales = info(:,3);
    conf_new = (conf_original-1)./(scales-1);    
    
    % save subject's data    
    % confidence
    conf.all(sub) = nanmean(conf_new(info(:,1)==1));    % across responses
    conf.correct(sub) = mean(conf_new(info(:,1)==1 & resp(:,3)==1,1));   % correct decision
    conf.incorrect(sub) = mean(conf_new(info(:,1)==1 & resp(:,3)==0,1)); % incorrect decision
    conf.high_coherence(sub) = mean(conf_new(info(:,1)==1 & info(:,2)==.08,1)); % high-coherence trials
    conf.low_coherence(sub) = mean(conf_new(info(:,1)==1 & info(:,2)==.04,1));  % low-coherence trials
    
    % decision accuracy
    acc.all(sub) = mean(resp(info(:,1)~=3,3));  % mean excluding catch trials
    acc.high_coherence(sub) = mean(resp(info(:,2)==.08,3)); % high_coherence trials
    acc.low_coherence(sub) = mean(resp(info(:,2)==.04,3));  % low_coherence trials
    
    % decision RT
    RT(sub) = mean(resp(:,1)); 
    
end

%% Task performance
clc;

% Accuracy across trials
mean(acc.all)
std(acc.all)

% Decision RT across trials
mean(RT)
std(RT)

% Accuracy high- vs. low-coherence trials and t-test
mean(acc.high_coherence)
std(acc.high_coherence)

mean(acc.low_coherence)
std(acc.low_coherence)

[h p c stats] = ttest(acc.high_coherence, acc.low_coherence);
pval = p
tval = stats.tstat
df = stats.df

%% Confidence responses
clc; 

% Average response
mean(conf.all)
std(conf.all)

% Correct vs. incorrect trials and t-test
mean(conf.correct)
std(conf.correct)

mean(conf.incorrect)
std(conf.incorrect)

[h p c stats] = ttest(conf.correct, conf.incorrect)
pval = p
tval = stats.tstat
df = stats.df

% High- vs. low-coherence trials and t-test
mean(conf.high_coherence)
std(conf.high_coherence)

mean(conf.low_coherence)
std(conf.low_coherence)

[h p c stats] = ttest(conf.high_coherence, conf.low_coherence)
pval = p
tval = stats.tstat
df = stats.df