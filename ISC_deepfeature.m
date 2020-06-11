% inter subject correlation
clear all
close all
load('fea_fc7_all_v3');
Ylabels(Ylabels==2) = 0;

expert = 1:11;
novice = 12:21;
confront = 1:9;
fight = 10:18;
nothing = 19:27;
play = 28:36;
actionset = {confront,fight,nothing,play};
groupset = {expert,novice};

%% correlation (individual frame)
%{
for action = 1:4
    
    for frame = 5:40
                
                %% correlation within each group (novice or expert) 
                for act = actionset{action}
                    
                    %for each action video, obtain 11 x 4096 matrix. Each row represents fc7 features for
                    %10 experts 
                    featureExp = fea_fc7_all(expert,:,frame,act);
                    
                    %10 x 4096, 10 fc7 feature vectors for 10 novice
                    featureNov = fea_fc7_all(novice,:,frame,act);
                    
                    %obtain correlation across experts. obtain 11-by-11
                    %correlation matrix
                    corExp = corr(featureExp');
                    
                    %get squareform and store mean of the correlations 
                    corExp(corExp==1) = 0; corExp = squareform(corExp);
                    corAll(action,act,frame,1) = mean(corExp);
                    
                    %the same process as the above
                    corNov = corr(featureNov');corNov(corNov==1) = 0; corNov = squareform(corNov);
                    corAll(action,act,frame,2) = mean(corNov);
                    
                    %obtain cosine distance between 11, 1-by-4096 vectors for the experts 
                    %and store mean of the distance for each group
                    cosdist(action,act,frame,1) = mean(pdist(featureExp, 'cosine'));
                    
                    %same as above
                    cosdist(action,act,frame,2) = mean(pdist(featureNov, 'cosine'));
                        
                end
                
                %for each action, obtain mean correlation across 9 videos
                corActMean(action,frame,1) = mean(corAll(action,actionset{action},frame,1));
                corActMean(action,frame,2) = mean(corAll(action,actionset{action},frame,2));
                
                %for each action, obtain mean cosine distance across 9
                %videos
                cosdistMean(action,frame,1) = mean(cosdist(action,actionset{action},frame,1));
                cosdistMean(action,frame,2) = mean(cosdist(action,actionset{action},frame,2));
                
                %mean of fc7 features across experts and novices
                featAll(action,:,frame,1) = mean(featureExp);
                featAll(action,:,frame,2) = mean(featureNov);
                
              
        
        %% for each action and frame, t test comparing the two groups
        [h(action, frame),p(action, frame),CI{action, frame},STATS(action, frame)] =...
            ttest(corAll(action,actionset{action},frame,1), corAll(action,actionset{action},frame,2));
        [h2(action, frame),p2(action, frame),CI2{action, frame},STATS2(action, frame)] =...
            ttest(cosdist(action,actionset{action},frame,1), cosdist(action,actionset{action},frame,2));
     
    
    end
    
    %for each action, across all frames, obtain t test results
    [h3(action),p3(action),CI3{action},STATS3(action)] =...
            ttest(corActMean(action,:,1), corActMean(action,:,2));
    [h4(action),p4(action),CI4{action},STATS4(action)] =...
            ttest(cosdistMean(action,:,1), cosdistMean(action,:,2));
end

%% plot
figure
sgtitle('p-values for correlation between experts and novices for each frame') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(p(action,:))
    ylim([0 1])
    title(actioncat{action})
end

figure
sgtitle('Comparing correlation between experts and novices for each frame') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(corAll(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 1])
        count = count+1;
    end
end

figure
sgtitle('Comparing correlation between experts and novices for each frame') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        plot(corActMean(action,:,group))
        title([actioncat{action} ' ' groupcat{group}])
        ylim([0 1])
        count = count+1;
    end
end

figure
sgtitle('p-values for cosine distance between experts and novices for each frame') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(p2(action,:))
    hold on
    plot(p(action,:))
    legend('cosine distance','correlation')
    ylim([0 1])
    title(actioncat{action})
end

figure
sgtitle('Comparing cosine distance between experts and novices for each frame') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(cosdist(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 0.5])
        count = count+1;
    end
end

figure
sgtitle('Comparing cosine distance between experts and novices for each frame') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        plot(cosdistMean(action,:,group))
        title([actioncat{action} ' ' groupcat{group}])
        ylim([0 0.5])
        count = count+1;
    end
end


% for each video, obtain the max correlation value and its corresponding
% index (frames 1~40)
for action = 1:4
    for group = 1:2
        [m i] = max(corAll(action,actionset{action},5:40,group),[],3);
        maxv(action,actionset{action},group) = m;
        index(action,actionset{action},group) = i+4;
    end
end

f = figure;
sgtitle('index of the highest correlation value for each video') 
count = 1;

for action = 1:4
    for group =1:2
        subplot(4,2,count)
        Y = index(action,actionset{action},group);
        sim = (abs(index(action,actionset{action},1) - index(action,actionset{action},2))<3);
        bar(Y,'r');
        hold on
        bar(Y.*sim);
        hold off
        text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center'); 
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

f = figure;
sgtitle('highest correlation values for each video') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        bar(maxv(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

%{
figure
sgtitle('fc7 features across frames') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(featAll(action,:,:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 1.2])
        count = count+1;
    end
end
%}

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cumulative correlation


%{
for action = 1:4
        
         for endp = 1:40
                    
                    %loop over videos for each action 
                    for act = actionset{action}
                        
                        %initialize empty matrix
                        featureExp = [];
                        featureNov = [];
                        
                        %loop over 1 to end frame
                        for frame = 1:endp

                            %for each action video, obtain 11 x 4096
                            %matrix, which is 11 fc7 feature vectors for 11 novice.
                            %Then, concatenate the new matrix with the
                            %previously concatenated matrix
                            featureExp = [featureExp fea_fc7_all(expert,:,frame,act)];

                            %The same process as above for novices
                            featureNov = [featureNov fea_fc7_all(novice,:,frame,act)];
                        end
                    
                        
                        %obtain correlation across experts. obtain 11-by-11
                        %correlation matrix
                        corExp = corr(featureExp');

                        %get squareform and store mean of the correlations 
                        corExp(corExp==1) = 0; corExp = squareform(corExp);
                        corAll(action,act,endp,1) = mean(corExp);

                        %the same process as the above
                        corNov = corr(featureNov');corNov(corNov==1) = 0; corNov = squareform(corNov);
                        corAll(action,act,endp,2) = mean(corNov);

                        %obtain cosine distance between 11, 1-by-4096*endp vectors for the experts 
                        %and store mean of the distance for each group
                        cosdist(action,act,endp,1) = mean(pdist(featureExp, 'cosine'));

                        %same as above
                        cosdist(action,act,endp,2) = mean(pdist(featureNov, 'cosine'));
                    end
                    
                    %t-tests to compare correlation between novice and
                    %expert
               
                    [h(action, endp),p(action, endp),CI{action, endp},STATS(action, endp)] =...
                    ttest(corAll(action,actionset{action},endp,1), corAll(action,actionset{action},endp,2));
            
                    %t-tests to compare cosine distance between novice and expert
                    [h2(action, endp),p2(action, endp),CI2{action, endp},STATS2(action, endp)] =...
                    ttest(cosdist(action,actionset{action},endp,1), cosdist(action,actionset{action},endp,2));


         end
    
            %% for each action and frame, t test comparing the two groups
            
           
      
   %{
    %for each action, across all frames, obtain t test results
    [h3(action),p3(action),CI3{action},STATS3(action)] =...
            ttest2(corActMean(action,:,1), corActMean(action,:,2));
    [h4(action),p4(action),CI4{action},STATS4(action)] =...
            ttest2(cosdistMean(action,:,1), cosdistMean(action,:,2));
      %}     
end

%% plot

figure
sgtitle('p-values for correlation between experts and novices for each cumulatation') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(p2(action,:))
    hold on
    plot(p(action,:))
    legend('cosine distance','correlation')

    ylim([0 1])
    title(actioncat{action})
end

actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
figure
sgtitle('Comparing correlation between experts and novices for each cumulatation') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(corAll(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0.5 1])
        count = count+1;
    end
end



figure
sgtitle('Comparing cosine distance between experts and novices for each cumulatation') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(cosdist(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 0.5])
        count = count+1;
    end
end



figure
sgtitle('p-values for correlation between experts and novices for each cumulatation') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(p2(action,:))
    ylim([0 1])
    title(actioncat{action})
end


% for each video, obtain the max correlation value and its corresponding
% index (cumulated frame groups 1~40)
for action = 1:4
    for group = 1:2
        [m i] = max(corAll(action,actionset{action},:,group),[],3);
        maxv(action,actionset{action},group) = m;
        index(action,actionset{action},group) = i;
    end
end


f = figure;
sgtitle('index of the highest correlation value for each video') 
count = 1;

for action = 1:4
    for group =1:2
        %uit = uitable(f);
        %d = [maxv(action,actionset{action},group)' index(action,actionset{action},group)'];
        %uit.Data = d;
        subplot(4,2,count)
        bar(index(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

f = figure;
sgtitle('highest correlation values for each video') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        bar(maxv(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

%}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% chunking 



chunks = {1:4,5:8,9:12,13:16,17:20,21:24,25:28,29:32,33:36,37:40};
for action = 1:4
        for chunk = 2:10

                    %% for each action, loop over videos 
                    for act = actionset{action}
                        featureExp1 = [];
                        featureNov1 = [];

                        for frame = chunks{chunk}

                        %for each action video, obtain 11 x 4096 matrix,
                        %each row representing fc7 features for each expert
                        %Then, concatenate the new matrix with the previous
                        %matrix
                            featureExp1 = [featureExp1 fea_fc7_all(expert,:,frame,act)];

                        %same as above
                            featureNov1 = [featureNov1 fea_fc7_all(novice,:,frame,act)];
                        end
                        
                        %obtain correlation across experts. obtain 11-by-11
                        %correlation matrix
                        corExp1 = corr(featureExp1');

                        %get squareform and store mean of the correlations 
                        corExp1(corExp1==1) = 0; corExp1 = squareform(corExp1);
                        corAll1(action,act,chunk,1) = mean(corExp1);

                        %the same process as the above
                        corNov1 = corr(featureNov1');corNov1(corNov1==1) = 0; corNov1 = squareform(corNov1);
                        corAll1(action,act,chunk,2) = mean(corNov1);

                        %obtain cosine distance between 11, 1-by-4096*4 vectors for the experts 
                        %and store mean of the distance for each group
                        cosdist1(action,act,chunk,1) = mean(pdist(featureExp1, 'cosine'));

                        %same as above
                        cosdist1(action,act,chunk,2) = mean(pdist(featureNov1, 'cosine'));

                    end
    
            %% for each action and frame, t test comparing the two groups
            
            
            [hchunk(action, chunk),pchunk(action, chunk),CIchunk{action, chunk},STATSchunk(action, chunk)] =...
                ttest(corAll1(action,actionset{action},chunk,1), corAll1(action,actionset{action},chunk,2));
            [hchunk2(action, chunk),pchunk2(action, chunk),CIchunk2{action, chunk},STATSchunk2(action, chunk)] =...
                ttest(cosdist1(action,actionset{action},chunk,1), cosdist1(action,actionset{action},chunk,2));

      
    end

end

%% plot

actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};

figure
sgtitle('Comparing correlation between experts and novices for each chunk') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(corAll1(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0.5 1])
        count = count+1;
    end
end

figure
sgtitle('p-values for cosine distance between experts and novices for each chunk') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(pchunk2(action,:))
    hold on
    plot(pchunk(action,:))
    legend('cosine distance','correlation')
    ylim([0 1])
    title(actioncat{action})
end

figure
sgtitle('Comparing cosine distance between experts and novices for each chunk') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(cosdist1(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 0.3])
        count = count+1;
    end
end



for action = 1:4
    for group = 1:2
        [m i] = max(corAll1(action,actionset{action},:,group),[],3);
        maxv(action,actionset{action},group) = m;
        index(action,actionset{action},group) = i;
    end
end


f = figure;
sgtitle('index of the highest correlation value for each video') 
count = 1;

for action = 1:4
    for group =1:2
        subplot(4,2,count)
        Y = index(action,actionset{action},group);
        sim = (abs(index(action,actionset{action},1) - index(action,actionset{action},2))<1);
        bar(Y,'r');
        hold on
        bar(Y.*sim);
        hold off
        text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center'); 
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

f = figure;
sgtitle('highest correlation values for each video') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        bar(maxv(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end


%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cumulation (mean)
%{
for action = 1:4
        
         for endp = 1:40
                    
                    %loop over videos for each action 
                    for act = actionset{action}
                        
                        %obtain mean features across 1 to "endp"th frame
                        featureExp = mean([fea_fc7_all(expert,:,1:endp,act)],3);
                        featureNov = mean([fea_fc7_all(novice,:,1:endp,act)],3);
                      
                        
                        %obtain correlation across experts. obtain 11-by-11
                        %correlation matrix
                        corExp = corr(featureExp');

                        %get squareform and store mean of the correlations 
                        corExp(corExp==1) = 0; corExp = squareform(corExp);
                        corAll(action,act,endp,1) = mean(corExp);

                        %the same process as the above
                        corNov = corr(featureNov');corNov(corNov==1) = 0; corNov = squareform(corNov);
                        corAll(action,act,endp,2) = mean(corNov);

                        %obtain cosine distance between 11, 1-by-4096*endp vectors for the experts 
                        %and store mean of the distance for each group
                        cosdist(action,act,endp,1) = mean(pdist(featureExp, 'cosine'));

                        %same as above
                        cosdist(action,act,endp,2) = mean(pdist(featureNov, 'cosine'));
                    end
                    
                    %t-tests to compare correlation between novice and
                    %expert
               
                    [h(action, endp),p(action, endp),CI{action, endp},STATS(action, endp)] =...
                    ttest2(corAll(action,actionset{action},endp,1), corAll(action,actionset{action},endp,2));
            
                    %t-tests to compare cosine distance between novice and expert
                    [h2(action, endp),p2(action, endp),CI2{action, endp},STATS2(action, endp)] =...
                    ttest2(cosdist(action,actionset{action},endp,1), cosdist(action,actionset{action},endp,2));


         end
    
            %% for each action and frame, t test comparing the two groups
            
           
      
   %{
    %for each action, across all frames, obtain t test results
    [h3(action),p3(action),CI3{action},STATS3(action)] =...
            ttest2(corActMean(action,:,1), corActMean(action,:,2));
    [h4(action),p4(action),CI4{action},STATS4(action)] =...
            ttest2(cosdistMean(action,:,1), cosdistMean(action,:,2));
      %}     
end

%% plot

figure
sgtitle('p-values for correlation between experts and novices for each cumulatation') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(p(action,:))
    ylim([0 1])
    title(actioncat{action})
end

actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
figure
sgtitle('Comparing correlation between experts and novices for each cumulatation') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(corAll(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0.8 1])
        count = count+1;
    end
end



figure
sgtitle('Comparing cosine distance between experts and novices for each cumulatation') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(cosdist(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 0.2])
        count = count+1;
    end
end



% for each video, obtain the max correlation value and its corresponding
% index (cumulated frame groups 1~40)
for action = 1:4
    for group = 1:2
        [m i] = max(corAll(action,actionset{action},:,group),[],3);
        maxv(action,actionset{action},group) = m;
        index(action,actionset{action},group) = i;
    end
end


f = figure;
sgtitle('index of the highest correlation value for each video') 
count = 1;

for action = 1:4
    for group =1:2
      
        subplot(4,2,count)
        bar(index(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

f = figure;
sgtitle('highest correlation values for each video') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        bar(maxv(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end


%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% chunking (grouping by mean)


%{

chunks = {2:4,5:8,9:12,13:16,17:20,21:24,25:28,29:32,33:36,37:40};
for action = 1:4
        for chunk = 1:10

                    %for each action, loop over 9 videos
                    for act = actionset{action}
                        
                        %for each action video, obtain 11 x 4096 matrix. Each row represents fc7 features for
                        %10 experts 
                        featureExp1 = mean(fea_fc7_all(expert,:,chunks{chunk},act),3);
                        featureNov1 = mean(fea_fc7_all(novice,:,chunks{chunk},act),3);
                        
                       
                        
                        %obtain correlation across experts. obtain 11-by-11
                        %correlation matrix
                        corExp1 = corr(featureExp1');

                        %get squareform and store mean of the correlations 
                        corExp1(corExp1==1) = 0; corExp1 = squareform(corExp1);
                        corAll1(action,act,chunk,1) = mean(corExp1);

                        %the same process as the above
                        corNov1 = corr(featureNov1');corNov1(corNov1==1) = 0; corNov1 = squareform(corNov1);
                        corAll1(action,act,chunk,2) = mean(corNov1);

                        %obtain cosine distance between 11, 1-by-4096 vectors for the experts 
                        %and store mean of the distance for each group
                        cosdist1(action,act,chunk,1) = mean(pdist(featureExp1, 'cosine'));

                        %same as above
                        cosdist1(action,act,chunk,2) = mean(pdist(featureNov1, 'cosine'));

                    end
    
            %% for each action and frame, t test comparing the two groups
            
            
            [hchunk(action, chunk),pchunk(action, chunk),CIchunk{action, chunk},STATSchunk(action, chunk)] =...
                ttest2(corAll1(action,actionset{action},chunk,1), corAll1(action,actionset{action},chunk,2));
            [hchunk2(action, chunk),pchunk2(action, chunk),CIchunk2{action, chunk},STATSchunk2(action, chunk)] =...
                ttest2(cosdist1(action,actionset{action},chunk,1), cosdist1(action,actionset{action},chunk,2));

      
    end

end

%% plot

actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};

figure
sgtitle('Comparing correlation between experts and novices for each chunk') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(corAll1(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0.5 1])
        count = count+1;
    end
end

figure
sgtitle('p-values for cosine distance between experts and novices for each chunk') 
actioncat = {'confront','fight','nothing','play'};
groupcat = {'expert','novice'};
for action = 1:4
    subplot(2,2,action)
    plot(pchunk2(action,:))
    hold on
    plot(pchunk(action,:))
    legend('cosine distance','correlation')
    ylim([0 1])
    title(actioncat{action})
end

figure
sgtitle('Comparing cosine distance between experts and novices for each chunk') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        imagesc(squeeze(cosdist1(action,actionset{action},:,group)))
        title([actioncat{action} ' ' groupcat{group}])
        colorbar
        caxis([0 0.3])
        count = count+1;
    end
end



for action = 1:4
    for group = 1:2
        [m i] = max(corAll1(action,actionset{action},:,group),[],3);
        maxv(action,actionset{action},group) = m;
        index(action,actionset{action},group) = i;
    end
end


f = figure;
sgtitle('index of the highest correlation value for each video') 
count = 1;

for action = 1:4
    for group =1:2
       
        subplot(4,2,count)
        Y = index(action,actionset{action},group);
        bar(Y);
        text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center'); 
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

f = figure;
sgtitle('highest correlation values for each video') 
count = 1;
for action = 1:4
    for group =1:2
        subplot(4,2,count)
        bar(maxv(action,actionset{action},group));
        title([actioncat{action} ' ' groupcat{group}])
        count = count+1;
    end
    
end

%}


