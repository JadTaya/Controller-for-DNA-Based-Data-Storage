%%%%%%%
% Remove leading zeros from Galois array
function gt = trim(g)
    gx = g.x;
    gt = gf(gx(find(gx, 1) : end), g.m, g.prim_poly);
end
