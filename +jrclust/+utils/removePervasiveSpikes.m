function [dRes, sRes] = removePervasiveSpikes(dRes, sRes, nSites)
%%
if isempty(dRes.isPervasive)
    return
end
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