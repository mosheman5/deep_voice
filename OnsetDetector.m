classdef OnsetDetector < handle
    
    properties
        
        % var object from the signal_analyzer
        var
        
        % entropy bounds - upper and lower freq bands for the whole entropy
        % business
        freq_bounds = [80, 1000];
        
        % do PCA? and if so, how much components to remove
        do_PCA
        
        stft_mag
        spectPsd
    end
    
    methods
        
        % Constructor for OnsetDetector
        function m = OnsetDetector(var, do_PCA)
            m.var = var;
            if nargin>1
                m.do_PCA = do_PCA;
            else
                m.do_PCA = 0;
            end
        end
        
        function spec_setup(m)
            %get mag matrix
            m.stft_mag = abs(m.var.b_mat);
            
            if m.do_PCA
                my_n_cleaner = NoiseCleaning();
                m.stft_mag = my_n_cleaner.PCA_mag(m.stft_mag, m.do_PCA);
            end
            
            % crop to window by freq_bounds
            pos1 = find(m.var.f_vec>m.freq_bounds(1),1,'first');
            pos2 = find(m.var.f_vec>m.freq_bounds(2),1,'first');
            
            m.stft_mag(1:pos1,:) = [];
            m.var.f_vec(1:pos1) = [];
            m.stft_mag(pos2:end,:) = [];
            m.var.f_vec(pos2:end) = [];
            
            % PSD and norm each time column to 1
            m.spectPsd = m.stft_mag.*conj(m.stft_mag);
            
            %             spectPsd = spectPsd./repmat(sum(spectPsd,1),size(spectPsd,1),1);
            %             m.stft_mag = spectPsd./repmat(sum(spectPsd,2),1,size(spectPsd,2));
            %             spectPsd = spectPsd/sum(sum(spectPsd));
        end
        
        
        function B = d2_ent_filter(m, f_window, t_window, threshold)
            % D2_ENT_FILTER - apply 2d entr�?py filter of size [f_window
            % t_window] on the spectorgram
            % threshold - display upper 1-threshold of the entropy
            
            m.spec_setup()
           
            
            % get conversion from the window (in Hz, sec) to pixels
            df = m.var.f_vec(2)-m.var.f_vec(1);
            Hz2pixel_f = 1/df;
            
            dt = m.var.t_vec(2)-m.var.t_vec(1);
            Hz2pixel_t = 1/dt;
            
            % function to be aplied to block (entrpy)
            fun = @(block_struct) entropy(block_struct.data);
            %             fun = @(block) entropy(block);
            
            % PSD and norm each time column to 1
            m.spectPsd = m.stft_mag.*conj(m.stft_mag);
            
            %             spectPsd = spectPsd./repmat(sum(spectPsd,1),size(spectPsd,1),1);
            m.spectPsd = m.spectPsd./repmat(sum(m.spectPsd,2),1,size(m.spectPsd,2));
            %             spectPsd = spectPsd/sum(sum(spectPsd));
            
            B =  blockproc(m.spectPsd, [1, 1],fun, ...
                'BorderSize',floor([Hz2pixel_f*f_window/2.0 Hz2pixel_t*t_window/2.0]),...
                'TrimBorder', false, 'PadPartialBlocks', true,'PadMethod','symmetric','UseParallel',false);
            
%             flow = [m.freq_bounds(1)+2*df 200 400 600 800];
%             fup = [200 400  600  800 m.freq_bounds(2)-2*df];
%             
%             se2 = zeros(length(flow),size(m.spectPsd,2));
%             for i = 1:length(flow)
%                 se2(i,:) =  pentropy(m.spectPsd,m.var.f_vec,m.var.t_vec,'FrequencyLimits',[flow(i) fup(i)]);
%             end
%             % respread on m.var.f_vec
%             [X, Y] = meshgrid(m.var.t_vec,(fup+flow)/2);
%             [Xq, Yq] = meshgrid(m.var.t_vec,m.var.f_vec);
%             pent_mat = interp2(X,Y,se2,Xq,Yq);
%             
            
            % thresh
            if ((nargin>3) && (threshold>0))
                B_thresh = max(max(B))*threshold;
                B = B>B_thresh;
            end
            % dispaly on sep figure
%             prev_f = gcf;
%             
%             new_f = figure;
%             
%             
%             figure(new_f)
%             
%             subplot(3,1,1)
%             imagesc( m.var.t_vec,m.var.f_vec,-B);
%             set(gca,'YDir','normal')
%             subplot(3,1,2)
%             imagesc( m.var.t_vec,m.var.f_vec,m.spectPsd);
%             set(gca,'YDir','normal')
%             subplot(3,1,3)
%             imagesc( m.var.t_vec,m.var.f_vec,pent_mat); 
%             set(gca,'YDir','normal') 
%             
%             figure(prev_f)
            
        end
        
        function E_filtered=Energy_Detector(m, threshold)
            
           spec_setup(m) %get spectogram into m.spectPsd and m.stft_mag
%            [pk_ind]=find(m.spectPsd>(1+threshold)*(mean(mean((m.spectPsd))))); %find indices of high energy points
           m.spectPsd = m.spectPsd./repmat(sum(m.spectPsd,2),1,size(m.spectPsd,2)); %normalize freq bins
           E_filtered=zeros(size(m.spectPsd));
%            E_filtered(pk_ind)=1;

           winSize=10; %size of local running block (on each side)
         for j=1:size(m.spectPsd,1)
             for k=1:size(m.spectPsd,2)
                 Ewin=min(winSize,size(m.spectPsd,2)-k);  %adapt number of block elements in each side for the matrix edges
                 Wwin=min(winSize,k-1);
%                  Swin=min(winSize,size(m.spectPsd,1)-j);
%                  Nwin=min(winSize,j-1);
                 Swin=size(m.spectPsd,1)-j;
                 Nwin=j-1; %all freqs window (rectangular)
                 
                 if(m.spectPsd(j,k)>(threshold+1)*(mean(mean(m.spectPsd(j-Nwin:j+Swin,k-Wwin:k+Ewin)))))
                     E_filtered(j,k)=1;
                 end
                 
             end
         end
          
%            E_filtered(pk_ind)=1; %create matrix of high points
%            CC=bwconncomp(E_filtered);
%            CC_centroids=cellfun(@(x) x(ceil(end/2)),CC.PixelIdxList);
%            [CCx,CCy]=ind2sub(size(E_filtered),CC_centroids);
           prev_f=gcf;
           new_f=figure;
           figure(new_f)
           subplot(2,1,1)
           imagesc(m.var.t_vec,m.var.f_vec,E_filtered);
           set(gca,'YDir','normal')
%            E_det_CC=insertShape(E_filtered,'Circle',[CCx',CCy',ones(length(CCx))]);  %mark connected parts
%            imshow(E_det_cc)
           subplot(2,1,2)
           imagesc(m.var.t_vec,m.var.f_vec,10*log10(m.spectPsd))
           set(gca,'YDir','normal')
%            colormap jet
           
           figure(prev_f);
           
            
                  
        end
        
        function time_domain_detector_plot(m)
            %time_domain_detector_plot - plots on the screen the entropy per
            %time step
            stft_mag = abs(m.var.b_mat);
            
            if m.do_PCA
                my_n_cleaner = NoiseCleaning();
                stft_mag = my_n_cleaner.PCA_mag(stft_mag, m.do_PCA);
            end
            
            spectPsd = stft_mag.*conj(stft_mag);
            
            pos1 = find(m.var.f_vec>m.freq_bounds(1),1,'first');
            pos2 = find(m.var.f_vec>m.freq_bounds(2),1,'first');
            
            spectPsd(1:pos1,:) = [];
            spectPsd(pos2:end,:) = [];
            
            %normalize each freq to a sum of 1
            % avgPsd = sum(spectPsd,2);
            % spectPsd = spectPsd./repmat(avgPsd,1,size(spectPsd,2));
            
            % calc ent
            ent = m.linear_entropy(spectPsd);
            
            hold on
            plot(m.var.t_vec,abs(-200*ent),'r','LineWidth',3)
            
        end
    end
    
    methods (Static = true)
        
        function ent = linear_entropy(vec)
            %ENTROPYPSD Entropy of a vec
            psdVec = vec./sum(vec);
            ent = -sum(psdVec.*log(psdVec));
        end
        
        function ent = d2_entropy(mat)
            %ENTROPYPSD Entropy of a mat
            psdVec = mat./sum(mat);
            psdVec = psdVec(:);
            ent = -sum(psdVec.*log(psdVec));
        end
        
        function ent_list = ent_per_cc(psd, CC)
            % ent_per_cc - return median entropy score per area in each CC
            % as a list
            % psd - the psd to calc the ent from
            
            ent_list = zeros(length(CC.PixelIdxList),1);
            
            for cc_ind = 1:length(CC.PixelIdxList)
                [I, J] = ind2sub(size(psd), CC.PixelIdxList{cc_ind});
                block_psd = psd(min(I):max(I), min(J):max(J));
                ent_list(cc_ind) = median(entropy(block_psd/sum(sum(block_psd))));
            end
        end
        
        function energy_list = energy_per_cc(spectPsd, CC)
            energy_list = zeros(length(CC.PixelIdxList),1);
            spectPsd = spectPsd./repmat(sum(spectPsd,2),1,size(spectPsd,2)); %normalize freq bins
             for cc_ind = 1:length(CC.PixelIdxList)
                [I, J] = ind2sub(size(spectPsd), CC.PixelIdxList{cc_ind});
                block_psd = spectPsd(min(I):max(I), min(J):max(J));
                energy_list(cc_ind) = mean(mean(block_psd));
             end    
        end
        
    end
    
end
