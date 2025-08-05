function democurve 
% Shows a simple test curve. 
%  
 
% D.M. Spink 
% Copyright (c) 2000 
 
crv = nrbtestcrv; 
 
% plot the control points 
plot(crv.coefs(1,:),crv.coefs(2,:),'ro'); 
title('Arbitrary Test 2D Curve.'); 
hold on; 
plot(crv.coefs(1,:),crv.coefs(2,:),'r--'); 
hold on;
 
% plot the nurbs curve 
nrbplot(crv,148); 
hold on; 
 
% crv.knots(3)=0.1; 
% 
% % plot the control points 
% plot(crv.coefs(1,:),crv.coefs(2,:),'ro'); 
% title('Arbitrary Test 2D Curve.'); 
% hold on; 
% plot(crv.coefs(1,:),crv.coefs(2,:),'r--'); 
%  
% % plot the nurbs curve 
% nrbplot(crv,48); 
% hold off; 
