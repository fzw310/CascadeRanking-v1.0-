function objPotentialBoxes = getObjBndBoxes( im3u, base, W, NSS, numDetPerSz, T, filterW )

BoxesSI = predictBBoxSI(im3u, base, W, NSS, numDetPerSz, T, filterW );
BoxesSII = predictBBoxSII(BoxesSI);
% BoxesSII = BoxesSI;

objPotentialBoxes = [];
for i = 1:length(BoxesSII)
    if isempty(BoxesSII{i}), continue; end
    objPotentialBoxes = cat(1, objPotentialBoxes, BoxesSII{i});
end

objPotentialBoxes = -sortrows(-objPotentialBoxes, 1);

objPotentialBoxes = objPotentialBoxes(:, 2:5);

end

function BoxesSII = predictBBoxSII( BoxesSI )

load svmModelII
BoxesSII = cell(1, length(BoxesSI));
for r = 1:length(BoxesSI)
    rBoxes = BoxesSI{r};
    if isempty(rBoxes), continue; end
    rBoxes(:, 1) = rBoxes(:, 1) .* svmModelII(r, 1) + svmModelII(r, 2);
    BoxesSII{r} = rBoxes;
end

end