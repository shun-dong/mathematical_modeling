function show3d(d,n)
%[]=SHOW3D(D,N)
%Virsual illustration of 3d wavelet tranform coefficients
%D is the packed coefficients of 3 dimensions
%N is a option to put aid lines onto image
%    if you omit N, there will be no aid line.
%    if you give N a value of int, then n means the layers of wavelet tranform.

[sx,sy,sz]=size(d);
clf;
%buttom
x=ones(sy+1,1)*[0:sx];
y=[0:sy]'*ones(1,sx+1);
z=zeros(sy+1,sx+1);
t=d(:,:,sz);
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');
%top
x=ones(sy+1,1)*[0:sx];
y=[0:sy]'*ones(1,sx+1);
z=ones(sy+1,sx+1)*sz;
t=d(:,:,1);
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');
%hold x=0;
x=zeros(sy+1,sz+1);
z=ones(sy+1,1)*[0:sz];
y=[0:sy]'*ones(1,sz+1);
t=fliplr(squeeze(d(:,1,:)));
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');
%hold x=sx
x=ones(sy+1,sz+1)*sx;
z=ones(sy+1,1)*[0:sz];
y=[0:sy]'*ones(1,sz+1);
t=fliplr(squeeze(d(:,sx,:)));
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');
%hold y=0
x=[0:sx]'*ones(1,sz+1);
y=zeros(sx+1,sz+1);
z=ones(sx+1,1)*[0:sz];
t=fliplr(squeeze(d(1,:,:)));
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');
%hold y=sy
x=[0:sx]'*ones(1,sz+1);
y=ones(sx+1,sz+1)*sy;
z=ones(sx+1,1)*[0:sz];
t=fliplr(squeeze(d(sy,:,:)));
h=surface(x,y,z);
set(h,'CData',t,'FaceColor','texturemap');

%Add aid lines
if nargin==2
   h=size(d);
   hold on;
   line(h(1)/2*ones(1,5),[0,0,h(2),h(2),0],[0,h(3),h(3),0,0]);
   line([0,0,h(1),h(1),0],h(2)/2*ones(1,5),[0,h(3),h(3),0,0]);
   line([0,0,h(1),h(1),0],[0,h(2),h(2),0,0],h(3)/2*ones(1,5));
   k=1;
   for i=2:n
      k=k*2;
      line([0,0],[h(2)/k/2,h(2)/k/2],[h(3)-h(3)/k,h(3)]);
      line([0,0],[0,h(2)/k],[h(3)-h(3)/k/2,h(3)-h(3)/k/2]);
      line([h(1)/k/2,h(1)/k/2],[0,0],[h(3)-h(3)/k,h(3)]);
      line([0,h(1)/k],[0,0],[h(3)-h(3)/k/2,h(3)-h(3)/k/2]);
      line([0,h(1)/k],[h(2)/k/2,h(2)/k/2],[h(3),h(3)]);
      line([h(1)/k/2,h(1)/k/2],[0,h(2)/k],[h(3),h(3)]);
   end;
   hold off;
end
%------------------------------------------

shading flat;
%axis off;
grid off;
view(3);

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
