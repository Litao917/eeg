function tf = isMcode(file)
% Both .m and .mlx are valid M-code.
    tf = hasext(file,'.m') | hasext(file,'.mlx');
end