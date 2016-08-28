function newBlock = blockAdjustment(im, magBlock, ColorBlock, filter1W, W)
[imRow, imCol, dim] = size(im);
[blockRow, blockCol] = size(magBlock);
% tmp = reshape(interUnionfzw(magBlock, ColorBlock), size(ColorBlock,1), size(magBlock,1));
%c,r,h,w
location = [1 1 2 2
            1 1 2 3
            1 1 2 4
            1 1 3 2
            1 1 3 3
            1 1 3 4
            1 1 4 2
            1 1 4 3
            1 1 4 4
            1 2 2 1
            1 2 2 2
            1 2 2 3
            1 2 3 1
            1 2 3 2
            1 2 3 3
            1 2 4 1
            1 2 4 2
            1 2 4 3
            1 3 2 0
            1 3 2 1
            1 3 2 2
            1 3 3 0
            1 3 3 1
            1 3 3 2
            1 3 4 0
            1 3 4 1
            1 3 4 2
            2 1 1 2
            2 1 1 3
            2 1 1 4
            2 1 2 2
            2 1 2 3
            2 1 2 4
            2 1 3 2
            2 1 3 3
            2 1 3 4
            2 2 1 1
            2 2 1 2
            2 2 1 3
            2 2 2 1
            2 2 2 2
            2 2 2 3
            2 2 3 1
            2 2 3 2
            2 2 3 3
            2 3 1 0
            2 3 1 1
            2 3 1 2
            2 3 2 0
            2 3 2 1
            2 3 2 2
            2 3 3 0
            2 3 3 1
            2 3 3 2
            3 1 0 2
            3 1 0 3
            3 1 0 4
            3 1 1 2
            3 1 1 3
            3 1 1 4
            3 1 2 2
            3 1 2 3
            3 1 2 4
            3 2 0 1
            3 2 0 2
            3 2 0 3
            3 2 1 1
            3 2 1 2
            3 2 1 3
            3 2 2 1
            3 2 2 2
            3 2 2 3
            3 3 0 0
            3 3 0 1
            3 3 0 2
            3 3 1 0
            3 3 1 1
            3 3 1 2
            3 3 2 0
            3 3 2 1
            3 3 2 2];
f = filter1W;
newBlock = [];
for i = 1:blockRow
    box = magBlock(i,:);
    exBox = [max(ceil(box(1) - box(3)/16),1), max(ceil(box(2) - box(4)/16), 1),...
        min(floor(box(1) + box(3)*17/16), imCol), min(floor(box(2) + box(4)*17/16), imRow)];%x1,y1,x2,y2
      
        subBox3u = imresize(im(exBox(2):exBox(4), exBox(1):exBox(3),:),...
            [12, 12], 'nearest'); % resize block 
        rationR = (exBox(4)-exBox(2)+1)/12;
        rationC = (exBox(3)-exBox(1)+1)/12;
        mag1f = computeNormedGradient(subBox3u);
        matchCost1f = reshape(dotfzw(mag1f, f), size(mag1f, 1) - W + 1, size(mag1f, 2) - W + 1);
        score = [];
        for j = 1 : size(location, 1)
            costBlock = matchCost1f(location(j, 1):location(j, 1) + location(j, 3), location(j, 2):location(j, 2) + location(j, 4));
            ratio = interUnionfzw([ceil(exBox(1) + (location(j, 2)-1) * rationC), ceil(exBox(2) + (location(j, 1)-1) * rationR), ...
                floor((location(j, 4) + W) * rationC), floor((location(j, 3) + W) * rationR)] , ColorBlock(i, :));
%             scoreBlcok = mean(mean(costBlock)) * ratio;
            scoreBlcok = ratio;
            score = [score; scoreBlcok];
        end
        [~, idx] = max(score);
        maxCostBlock = location(idx, :);
        imgBlock = [ceil(exBox(1) + (maxCostBlock(2)-1) * rationC), ceil(exBox(2) + (maxCostBlock(1)-1) * rationR), ...
            floor((maxCostBlock(4) + W) * rationC), floor((maxCostBlock(3) + W) * rationR)];
        newBlock = [newBlock; imgBlock];
      
%      tmp1 = im(imgBlock(2):(imgBlock(2) + imgBlock(4)-1), imgBlock(1):imgBlock(1) + imgBlock(3)-1, :); 
%      tmp2 = im(box(2):(box(2) + box(4)-1), box(1):box(1) + box(3)-1, :);
%      subplot(1,2,1),imshow(tmp2);
%      subplot(1,2,2),imshow(tmp1);        

end


end