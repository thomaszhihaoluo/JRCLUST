function updateFigCorr(obj)
    %UPDATEFIGCORR Plot cross correlation
    if isempty(obj.selected) || ~obj.hasFig('FigCorr')
        return;
    end

    plotFigCorr(obj.hFigs('FigCorr'), obj.hClust, obj.hCfg, obj.selected);
end

%% LOCAL FUNCTIONS
function hFigCorr = plotFigCorr(hFigCorr, hClust, hCfg, selected)
    %DOPLOTFIGCORR Plot timestep cross correlation
    if numel(selected) == 1
        iCluster = selected(1);
        jCluster = iCluster;
    else
        iCluster = selected(1);
        jCluster = selected(2);
    end

    jitterMs = 1; % bin size for correlation plot
    nLagsMs = 10; % show 25 msec

    jitterSamp = round(jitterMs*hCfg.sampleRate/1000); % 0.5 ms
    nLags = round(nLagsMs/jitterMs);

    iTimes = int32(double(hClust.spikeTimes(hClust.spikesByCluster{iCluster}))/jitterSamp);

    if iCluster ~= jCluster
        iTimes = [iTimes, iTimes - 1, iTimes + 1]; % check for off-by-one
    end
    jTimes = int32(double(hClust.spikeTimes(hClust.spikesByCluster{jCluster}))/jitterSamp);

    % count agreements of jTimes + lag with iTimes
    lagSamp = [-nLags:-1, 1:nLags];
    intCount = zeros(size(lagSamp));
    for iLag = 1:numel(lagSamp)
        if iCluster == jCluster && lagSamp(iLag)==0
            continue;
        end
        intCount(iLag) = numel(intersect(iTimes, jTimes + lagSamp(iLag)));
    end

    lagTime = lagSamp*jitterMs;
    lagTime(lagTime< 0) = lagTime(lagTime< 0)+0.5;
    lagTime(lagTime>0) = lagTime(lagTime> 0)-0.5;

    % draw the plot
    if ~hFigCorr.hasAxes('default')
        hFigCorr.addAxes('default');
        hFigCorr.addPlot('hBar', @bar, lagTime, intCount, 1);
        hFigCorr.axApply('default', @xlabel, 'Time (ms)');
        hFigCorr.axApply('default', @ylabel, 'Counts');
        hFigCorr.axApply('default', @grid, 'on');
        hFigCorr.axApply('default', @set, 'YScale', 'log');
    else
        hFigCorr.updatePlot('hBar', lagTime, intCount);
        hFigCorr.axApply('default', @set, 'YScale', 'log');
        y_max = 10^ceil(log10(max(intCount)));
        y_max = max(y_max, 1);
        hFigCorr.axApply('default', @set, 'YLim', [0.1, y_max], ...
                                          'YTick', [0.1, 10.^(0:log10(y_max))], ...
                                          'yticklabel', [{'0'}, cellfun(@num2str, num2cell(10.^(0:log10(y_max))), 'uni', 0)])
        hFigCorr.axApply('default', @set, 'Xtick', -nLagsMs:jitterMs:nLagsMs);
        hFigCorr.axApply('default', @grid, 'on');
    end

    if iCluster ~= jCluster
        hFigCorr.axApply('default', @title, sprintf('Unit %d vs. Unit %d', iCluster, jCluster));
    else
        hFigCorr.axApply('default', @title, sprintf('Unit %d', iCluster));
    end
    hFigCorr.axApply('default', @set, 'XLim', jitterMs*[-nLags, nLags]);
end
