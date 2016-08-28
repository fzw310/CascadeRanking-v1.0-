function drawBox(BestLocation, VOCPath, testStruct, NUM_test)
ResPath = 'F:\objecness(fzw)\公共数据库\Loc\';
for i = 1:NUM_test
    fileName = testStruct(i).annotation.filename;
    im = imread(fullfile(VOCPath, fileName)); % load image  
    BlockLocation = BestLocation{i};
    for j = 1:size(BlockLocation, 1);
        im(BlockLocation(j, 2):BlockLocation(j, 2) + BlockLocation(j, 4) - 1, BlockLocation(j, 1), :) = 255;
        im(BlockLocation(j, 2):BlockLocation(j, 2) + BlockLocation(j, 4) - 1, BlockLocation(j, 1) + BlockLocation(j, 3) - 1, :) = 255;
        im(BlockLocation(j, 2), BlockLocation(j, 1):BlockLocation(j, 1) + BlockLocation(j, 3) - 1, :) = 255;
        im(BlockLocation(j, 2) + BlockLocation(j, 4) - 1, BlockLocation(j, 1):BlockLocation(j, 1) + BlockLocation(j, 3) - 1, :) = 255;
    end
%     imshow(im);
    imwrite(im,strcat(ResPath, fileName),'jpg');
end
end