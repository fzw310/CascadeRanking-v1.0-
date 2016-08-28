function [bbs, bbR] = gtBndBoxSampling( gtbb, base, T )
%GTBNDBOXSAMPLING generate some extra positive training data
%

wVal = gtbb(:, 3); hVal = gtbb(:, 4);
wVal = log(wVal) ./ T.logBase; hVal = log(hVal) ./ T.logBase;
wMin = max(floor(wVal - 0.5), T.minT); wMax = min(floor(wVal + 1.5), T.maxT);
hMin = max(floor(hVal - 0.5), T.minT); hMax = min(floor(hVal + 1.5), T.maxT);

w = [wMin; wMin; wMin; wMin + 1; wMin + 1; wMin + 1; wMax; wMax; wMax];
h = [hMin; hMin + 1; hMax; hMin; hMin + 1; hMax; hMin; hMin + 1; hMax];

wT = base .^ w; hT = base .^ h;
bbs = [repmat(gtbb(:, 1:2), 9, 1), wT, hT];
IDX = sum(interUnion(bbs, gtbb) >= 0.5, 1) > 0;
bbs = bbs(IDX, :);
bbR = sz2idx(w(IDX), h(IDX), T);

end

function r = sz2idx( w, h, T )
    w = w - T.minT; 
    h = h - T.minT;
    if sum(w >= 0 & h >= 0 & w < T.numT & h < T.numT) == length(w)
        r = h * T.numT + w + 1;
    else
        error('wrong w and h.')
    end
end

