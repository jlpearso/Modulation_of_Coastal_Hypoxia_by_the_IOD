diff_doxy = circshift(doxy,-1) - doxy;
diff_doxy = diff_doxy(1:end-1,:);

diff_temp = circshift(temp,-1) - temp;
diff_temp = diff_temp(1:end-1,:);

diff_pres = circshift(pres,-1) - pres;
diff_pres = diff_pres(1:end-1);

% centered_pres = pres(2:end-1);
% centered_pres = repmat(centered_pres, [1,size(diff_temp,2)]);