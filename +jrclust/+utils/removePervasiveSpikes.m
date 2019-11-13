function [dRes, sRes] = removePervasiveSpikes(dRes, sRes, nSites)
% if size(dRes.centerSites, 2) > 0
%     dRes.spikeSites = dRes.centerSites(:, 1);
%     dRes.spikesBySite = arrayfun(@(iSite) find(dRes.centerSites(:, 1) == iSite), 1:nSites, 'UniformOutput', 0);
% else
%     dRes.spikeSites = [];
%     dRes.spikesBySite = cell(1, nSites);
% end
% if size(dRes.centerSites, 2) > 1
%     dRes.spikeSites2 = dRes.centerSites(:, 2);
%     dRes.spikesBySite2 = arrayfun(@(iSite) find(dRes.centerSites(:, 2) == iSite), 1:nSites, 'UniformOutput', 0);
% else
%     dRes.spikeSites2 = [];
%     dRes.spikesBySite2 = cell(1, nSites);
% end
% 
% if size(dRes.centerSites, 2) > 2
%     dRes.spikeSites3 = dRes.centerSites(:, 3);
%     dRes.spikesBySite3 = arrayfun(@(iSite) find(dRes.centerSites(:, 3) == iSite), 1:nSites, 'UniformOutput', 0);
% else
%     dRes.spikeSites3 = [];
%     dRes.spikesBySite3 = cell(1, nSites);
% end
% dRes.spikePositions = dRes.spikePositions(~dRes.isPervasive, :);
%%
sRes.spikeClusters = sRes.spikeClusters(~dRes.isPervasive,1);
sRes.spikeTemplates = sRes.spikeTemplates(~dRes.isPervasive,1);
sRes.amplitudes = sRes.amplitudes(~dRes.isPervasive,1);
sRes.templateFeatures = sRes.templateFeatures(:, ~dRes.isPervasive);
sRes.pcFeatures = sRes.pcFeatures(:, :, ~dRes.isPervasive);

clusters_remaining = unique(sRes.spikeClusters);
sRes.simScore = sRes.simScore(clusters_remaining,clusters_remaining);
sRes.templateFeatureInd = sRes.templateFeatureInd(:, clusters_remaining);
sRes.pcFeatureInd = sRes.pcFeatureInd(:, clusters_remaining);

for field = {'spikeClusters', 'spikeTemplates', 'templateFeatureInd',  'pcFeatureInd'}
    field = field{:};
    [unique_clusters, ~, indices] =unique(sRes.(field));
    new_clusters = 1:numel(unique_clusters);
    size_0 = size(sRes.(field));
    sRes.(field) = new_clusters(indices);
    sRes.(field) = reshape(sRes.(field), size_0);
end
disp('removed pervasive spikes')