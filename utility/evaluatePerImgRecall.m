function [recall,avgScore,BestLocation] = evaluatePerImgRecall(objPotentialBoxes, gtTestBoxes, NUM_WIN, NUM_test)

% NUM_test = length(objPotentialBoxes);
recall = [];
avgScore = [];
BestLocation = cell(1,NUM_test);
noBlockImg = 0;
for i = 1:NUM_test
    recallOne = zeros(NUM_WIN, 1);

    gtTestBox = gtTestBoxes{i};
    if size(gtTestBox,1) == 0
        noBlockImg = noBlockImg + 1;
        continue;
    end
    objPotentialBox = objPotentialBoxes{i};
    
    ratio = interUnion(objPotentialBox, gtTestBox);
    
    % find the first detected index that grater than 0.5
    [~, idx_vec] = max(ratio >= 0.5, [], 2);
    idx_vec(ratio(sub2ind(size(ratio), 1:length(idx_vec), idx_vec')) < 0.5) = [];
    idx_vec = sort(idx_vec);
    abo = sum(max(ratio,[],2))/size(ratio, 1);
    [~,MaxIdx] = max(ratio,[],2);
    BestLocation{i} = objPotentialBox(MaxIdx,:);
    for j = length(idx_vec):-1:1
        recallOne(idx_vec(j):end) = recallOne(idx_vec(j):end) + 1;
    end
    
    recallOne = recallOne / size(gtTestBox, 1);
    recall = cat(2, recall, recallOne);
    avgScore = cat(1, avgScore, abo);
end
recall = sum(recall, 2) / (NUM_test-noBlockImg);
avgScore = sum(avgScore)/(NUM_test-noBlockImg);
idx = [1,10,100,200, 210, 220, 230 240, 250 ,300,400,500,600,610, 620,630, 640,650,660,670,680,690,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,3000,5000];
for j = 1:length(idx) 
    fprintf('Recall at %d : %f\n', idx(j), recall(idx(j)) * 100);
end
fprintf('avgScore is = %f\n', avgScore * 100);

% fprintf('Recall at 1000: %f.\n', recall(1000) * 100)
% fprintf('Recall at 2000: %f.\n', recall(2000) * 100)
% fprintf('Recall at 5000: %f.\n', recall(5000) * 100)

end