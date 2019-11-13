function spikeData = findPervasive(obj, spikeData)
    %FINDPERVASIVE Identify spikes that appear in larger than usual number
    %of channels    
    samplesRaw = spikeData.samplesRaw;
    samplesFilt = spikeData.samplesFilt;
    spikeTimes = spikeData.spikeTimes;
    spikeSites = spikeData.spikeSites;

    nSpikes = numel(spikeTimes);
    nSitesEvt = 1 + obj.hCfg.nSiteDir*2; % includes ref sites

    % tensors, nSamples{Raw, Filt} x nSites x nSpikes
    spikesRaw = zeros(diff(obj.hCfg.evtWindowRawSamp) + 1, nSitesEvt, nSpikes, 'like', samplesRaw);
    spikesFilt = zeros(diff(obj.hCfg.evtWindowSamp) + 1, nSitesEvt, nSpikes, 'like', samplesFilt);

    % Realignment parameters
    spikeTimes = jrclust.utils.tryGpuArray(spikeTimes, obj.hCfg.useGPU);
    spikeSites = jrclust.utils.tryGpuArray(spikeSites, obj.hCfg.useGPU);    
    
    samplesRaw = jrclust.utils.tryGpuArray(samplesRaw, obj.hCfg.useGPU);
    samplesRaw = single(samplesRaw) - nanmean(samplesRaw, 1); % CAR
    spikesRaw = permute(obj.extractWindows(samplesRaw, spikeTimes, [], 1), [1, 3, 2]); % extractWindows returns nSamples x nSpikes x nSites
    
    for c = 1:size(samplesRaw,1)
        
    end
    
    RMS = rms(samplesRaw);
    peaksRaw = squeeze(max(abs(spikesRaw), [], 1));
    suprathresh = peaksRaw > obj.hCfg.qqFactor*RMS(:);
    nSiteSuprathresh = sum(suprathresh);    
    
    n_sites_max = obj.hCfg.getOr('n_sites_max', 8); % eight is default
    if max(obj.hCfg.siteLoc(:,2)) - min(obj.hCfg.siteLoc(:,2)) < 3840
        n_sites_max = n_sites_max * 2; % if only one bank were recorded, the density is higher
    end
    isPervasive = nSiteSuprathresh>n_sites_max;
    isPervasive = isPervasive(:);
    samplesRaw = jrclust.utils.tryGather(samplesRaw);
    spikeData.isPervasive = jrclust.utils.tryGather(isPervasive);
    %%
    spikeData.spikeTimes = spikeData.spikeTimes(~spikeData.isPervasive,1);
    spikeData.spikeAmps = spikeData.spikeAmps(~spikeData.isPervasive,1);
    spikeData.spikeSites = spikeData.spikeSites(~spikeData.isPervasive,1);
%     spikeData.spikesRaw = spikeData.spikesRaw(:,:,~spikeData.isPervasive);
%     spikeData.spikesFilt = spikeData.spikesFilt(:,:,~spikeData.isPervasive);    
    %% For debugging
    plotting = false;
    if plotting 
        inds = find(isPervasive);
        i = inds(306);
        figure
        supra_sites = find(suprathresh(:,i));
        for s = supra_sites(:)'
            plot(spikesRaw(:, s, i), 'k-', 'lineWidth', 0.5)
        end
        plot(spikesRaw(:, spikeSites(i), i), 'b-', 'lineWidth', 2)
    end
end