cs1 = s1;
cs2 = s2;

ori1 = orientation.rand(1000,cs1);
ori2 = orientation.rand(1000,cs2);

ax2 = axis(ori1,ori2);

plot(ax)

%%

pOri2 = project2FundamentalRegion(ori2, ori1);
grod = inv(pOri2) .* ori1;

ax2 = ori1 .* grod.axis('noSymmetry')

figure
histogram(angle(ax,ax2)./degree)

%%



o1 = reshape(ori1,20,50);
o2 = reshape(ori2,20,50);

[l,d,r] = factor(o1.CS.properGroup,o2.CS.properGroup);
l = l * d;
% we are looking for l,r from L and R such that
% angle(o1*l , o2*r) is minimal
% this is equivalent to
% angle(inv(o2)*o1 , r*inv(l)) is minimal

mori = inv(o2) .* o1; %#ok<*MINV>
idSym = r * inv(l);

d = -inf(size(mori));
idMax = ones(size(mori));
for id = 1:length(idSym)
  dLocal = dot(mori,idSym(id),'noSymmetry');
  idMax(dLocal > d) = id;
  d = max(d,dLocal);
end

% this projects mori into the fundamental zone
[row,col] = ind2sub(size(idSym),idMax);
pMori = times(inv(r(row)), mori, 0) .* l(col); 

% now the misorientation axis is given by in specimen coordinates is
% given by o2 * l(col) * q.axis or equivalently by
ax = times(o1, l(col), 1) .* axis(pMori);
%ax  = times(o2, r(row), 1).* axis(pMori);
ax2 = axis(o1,o2)

histogram(angle(ax(:),ax2(:)))

%%

histogram(angle(ax,ax2))

