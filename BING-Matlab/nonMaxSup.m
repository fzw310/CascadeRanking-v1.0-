function matchCost = nonMaxSup(mat, step, numDetPerSz)

% matt = filter2(fspecial('average', 3), mat);

% mat(matt - mat > 0) = -inf; 

count = 0;
matchCost = struct('x', [], 'y', [], 'socre', []);

while(max(mat(:))) ~=  -inf
    socre = max(mat(:));
    [r, c] = find(mat == socre, 1, 'first');
    matchCost.socre = cat(1, matchCost.socre, socre);
    matchCost.x = cat(1, matchCost.x, c - step);
    matchCost.y = cat(1, matchCost.y, r - step);
    mat(r-step:r+step, c-step:c+step) = -inf;
    count = count + 1;
    if count == numDetPerSz, break; end    
end

end
