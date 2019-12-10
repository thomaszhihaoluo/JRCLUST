function spikeData = removeRedundant(obj, spikeData)
    %REMOVEREDUNDANT Identify spikes that occured at the exact same    
    samplesRaw = spikeData.samplesRaw;
    samplesFilt = spikeData.samplesFilt;
    spikeTimes = spikeData.spikeTimes;
    spikeSites = spikeData.spikeSites;

    nSpikes = numel(spikeTimes);
    nSitesEvt = 1 + obj.hCfg.nSiteDir*2; % includes ref sites

    % tensors, nSamples{Raw, Filt} x nSites x nSpikes
    spikesRaw = zeros(diff(obj.hCfg.evtWindowRawSamp) + 1, nSitesEvt, nSpikes, 'like', samplesRaw);
    spikesFilt = zeros(diff(obj.hCfg.evtWindowSamp) + 1, nSitesEvt, nSpikes, 'like', samplesFilt);
    
    samplesRaw = jrclust.utils.tryGpuArray(samplesRaw, obj.hCfg.useGPU);
    samplesRaw = single(samplesRaw) - nanmean(samplesRaw, 1); % CAR
    spikesRaw = permute(obj.extractWindows(samplesRaw, spikeTimes, [], 1), [1, 3, 2]); % extractWindows returns nSamples x nSpikes x nSites
    
    spikeSites = double(spikeSites);
    
    spike_time_ms = double(spikeTimes)/obj.hCfg.sampleRate*1000;
    vl_subms = diff(spike_time_ms) < 0.1 & ...    % time difference
               abs(diff(spikeSites)) <10; % nearby 
    vi_subms = find(vl_subms);
    for i = vi_subms(:)'
        sites = [spikeSites(i), spikeSites(i+1)]; % could be the same
        wave1 = squeeze(spikesRaw(:,sites,i));
        wave2 = squeeze(spikesRaw(:,sites,i+1));
        x = 1;
        
    end
    %% debugging
    for debug_here = 1
        figure
        subplot(1,2,1)
        plot(wave1(:,1)); hold on; plot(wave2(:,1))
        fig_plot_yline(9)
        subplot(1,2,2)
        plot(wave1(:,2)); hold on; plot(wave2(:,2))
        fig_plot_yline(9)
    end
    
    %% Realignment parameters
    spikeTimes = jrclust.utils.tryGpuArray(spikeTimes, obj.hCfg.useGPU);
    spikeSites = jrclust.utils.tryGpuArray(spikeSites, obj.hCfg.useGPU);    
    
    
    
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
end