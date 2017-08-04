function hggetdisp(h)
    p = properties(h);
    sp = sort(p).';
    v = get(h,sp);
    o = cell2struct(v,sp,2);
    disp(o)
end