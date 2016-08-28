function [recall,avgScore,BestLocation] = evaluatePerImgRecall(objPotentialBoxes, gtTestBoxes, NUM_WIN, NUM_test)

% NUM_test = length(objPotentialBoxes);
recall = [];
avgScore = [];
BestLocation = cell(1,NUM_test);
% for i = 1:NUM_test
    recallOne = zeros(NUM_WIN, 1);

    gtTestBox = gtTestBoxes;
    objPotentialBox = objPotentialBoxes;
    
    ratio = interUnion(objPotentialBox, gtTestBox);
    
    % find the first detected index that grater than 0.5
    [~, idx_vec] = max(ratio >= 0.5, [], 2);
    idx_vec(ratio(sub2ind(size(ratio), 1:length(idx_vec), idx_vec')) < 0.5) = [];
    idx_vec = sort(idx_vec);
    abo = sum(max(ratio,[],2))/size(ratio, 1);
    [~,MaxIdx] = max(ratio,[],2);
%     firstIdx = [];
%     for i = 1 : size(ratio, 1)
%         if isempty(find(ratio(i, :) >= 0.5, 1 , 'first') )
%             firstIdx = [firstIdx; size(ratio, 2)];
%         else
%             firstIdx = [firstIdx; find(ratio(i, :) >= 0.5, 1 , 'first')];
%         end
%     end
    ratioMx = [];
    for i = 1 : size(ratio, 1)
        ratioMx = [ratioMx; ratio(i, MaxIdx(i, 1))];
    end
    BestLocation = objPotentialBox(MaxIdx,:);
    BestLocation = [MaxIdx, BestLocation, ratioMx];
    for j = length(idx_vec):-1:1
        recallOne(idx_vec(j):end) = recallOne(idx_vec(j):end) + 1;
    end
    
    recall = recallOne / size(gtTestBox, 1);
%     recall = cat(2, recall, recallOne);
%     avgScore = cat(1, avgScore, abo);
% end
% recall = sum(recall, 2) / NUM_test;
% avgScore = sum(avgScore)/NUM_test;

end