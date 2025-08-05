x=zeros(sy,sz);
z=ones(sy,1)*[0:sz-1];
y=([0:sz-1]'*ones(1,sy))';
t=squeeze(d(:,1,:));
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');

» f=[cat(3,v{1},v{2}),cat(3,v{3},v{4});cat(3,v{5},v{6}),cat(3,v{7},v{8})];

» view(180-37.5,30)