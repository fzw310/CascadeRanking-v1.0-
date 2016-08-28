function matchCost = nonMaxSup(mat, step, numDetPerSz, ColorboxesRecLayerRate)
count = 0;
supPointNumTotal = 0;
matchCost = struct('x', [], 'y', [], 'socre', []);

while(max(mat(:))) ~=  -inf
    socre = max(mat(:));
    [r, c] = find(mat == socre, 1, 'first');
    
    matchCost.socre = cat(1, matchCost.socre, socre);
    matchCost.x = cat(1, matchCost.x, c - step);
    matchCost.y = cat(1, matchCost.y, r - step);
    supPointNum = length(find(mat(r-step:r+step, c-step:c+step) ~= -inf));
    mat(r-step:r+step, c-step:c+step) = -inf;
    supPointNumTotal = supPointNumTotal + supPointNum;    
    count = count + 1;
    if supPointNumTotal >= ColorboxesRecLayerRate * ((size(mat,1)-2*step) * (size(mat,2)-2*step)),break; end
    if count == numDetPerSz, break; end    
end

end
