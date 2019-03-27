classdef NoiseCleaning
    %NOISECLEANING put here all methods to clean noise
    
    properties
        
    end
    
    methods (Static = true)
        function  spl = PCA_mag(stft_mag, num_of_com, first_f, last_f)
            % PCA_mag - removes num_of_com components from the PCA of the
            % magnitude in stft_mag
            % Controled parametes: number of compononets to reduce, gain
            % added after PCA
            
            spl=20*log10(stft_mag+eps);
            spl_for_max = spl(first_f:last_f, :);
            max_old = max(spl_for_max(:));
            
            [U, S, V] = svd(spl, 'econ');
            for i=1:num_of_com
                S(i,i) = 0;
            end
            spl = U*S*V';
            % power compensation becasue of pca
            spl_max = max(spl(:));
            spl = spl + (max_old - spl_max);
            
        end
        
        function  CC = cpp(spl, percentile, min_cc)
            % cpp - removes connected components from the spl, while
            % thresholding energy
            
            spl_bw = spl;
            power_threshold = prctile(spl,percentile);
            spl_bw(spl_bw<=power_threshold) = 0;
            spl_bw(spl_bw>power_threshold) = 1;
            CC = bwconncomp(spl_bw, 8);
            numPixels = cellfun(@numel,CC.PixelIdxList);
            
            
            CC.PixelIdxList(numPixels<min_cc) = [];
            
        end
        
        function spl = marked_cc_mag(spl, CC, upper_ent_thresh)
            spl_max = max(spl(:));
            spl_bw = spl;

            ent_list = OnsetDetector.ent_per_cc(10.^(spl./10), CC);
            
            CC.PixelIdxList(ent_list>upper_ent_thresh) = [];
            
            for index=1:length(CC.PixelIdxList)
                spl_bw(CC.PixelIdxList{index}) = 0;
            end
            B = bwboundaries(logical(spl_bw));
            for ind = 1:length(B)
                boundary = B{ind};
                spl(sub2ind(size(spl),boundary(:,1),boundary(:,2))) = spl_max;
            end     
        end
        
        function spl = final_display(spl, CC, upper_ent_thresh)
            spl_bw = spl;
            ent_list = OnsetDetector.ent_per_cc(10.^(spl./10), CC);
            CC.PixelIdxList(ent_list>upper_ent_thresh) = [];
            [m,n] = size(spl);
            spl = -200*ones(m,n);
            for index=1:length(CC.PixelIdxList)
                spl(CC.PixelIdxList{index}) = spl_bw(CC.PixelIdxList{index});
            end
        end
        
        function spl= marked_cc_after_energy(spl,CC, energy_thresh)
                        spl_max = max(spl(:));
            spl_bw = spl;
            energy_list = OnsetDetector.energy_per_cc(10.^(spl./10), CC);
            CC.PixelIdxList(energy_list>energy_thresh) = [];
            
            for index=1:length(CC.PixelIdxList)
                spl_bw(CC.PixelIdxList{index}) = 0;
            end
            B = bwboundaries(logical(spl_bw));
            for ind = 1:length(B)
                boundary = B{ind};
                spl(sub2ind(size(spl),boundary(:,1),boundary(:,2))) = spl_max;
            end
        end
        
    end
end

