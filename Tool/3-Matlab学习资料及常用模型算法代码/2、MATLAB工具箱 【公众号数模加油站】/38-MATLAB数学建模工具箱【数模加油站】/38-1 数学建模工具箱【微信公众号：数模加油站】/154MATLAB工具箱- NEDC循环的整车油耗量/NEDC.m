%UNTITLED 计算一个NEDC循环的整车油耗量
%   整车的参数
m=1350; g=9.8; r=0.307;
Gear_Ratio_MAPOp=[3.62,2.22,1.51,1.08,0.85];
ig0=3.0;nT=0.92; f=0.0084;CdA=2.4;pg=7.448;Iw=1.02;If=0.134;
%   加载NEDC循环工况路谱
A=xlsread('D:\NEDC.xls');
t=A(:,1);
v=A(:,2);
a=A(:,3);
%循环累计得出NEDC工况下的油耗条件
for i=1:1:1180;
    t(i)=i-1;
    a(i)=interp1(t,a,t(i),'linear'); %插值求出每一时刻的加速度
    v(i)=interp1(t,v,t(i),'linear'); %插值求出每一时刻的速度
%定义各个挡位的换挡速度
  u12=10;  u21=7;
    u23=20;  u32=15;
    u34=34;  u43=30;
    u45=50;  u54=45;
if i==1
        Gear_Ratio(i)=Gear_Ratio_MAPOp(1);
else
        Gear_Ratio(i)=Gear_Ratio(i-1);
end
    gear=Gear_Ratio(i);
switch (gear)
    case {Gear_Ratio_MAPOp(1)}
        if v(i)>=u12
            Gear_Ratio(i)=Gear_Ratio_MAPOp(2);
        end
    case {Gear_Ratio_MAPOp(2)}
        if v(i)>=u23
            Gear_Ratio(i)=Gear_Ratio_MAPOp(3);
        elseif v(i)<=u21
            Gear_Ratio(i)=Gear_Ratio_MAPOp(1);
        end
    case {Gear_Ratio_MAPOp(3)}
        if v(i)>=u34
            Gear_Ratio(i)=Gear_Ratio_MAPOp(4);
        elseif v(i)<=u32
            Gear_Ratio(i)=Gear_Ratio_MAPOp(2);
        end
    case {Gear_Ratio_MAPOp(4)}
        if v(i)>=u45
            Gear_Ratio(i)=Gear_Ratio_MAPOp(5);
        elseif v(i)<=u43
            Gear_Ratio(i)=Gear_Ratio_MAPOp(3);
        end
    case {Gear_Ratio_MAPOp(5)}
        if v(i)<=u54
            Gear_Ratio(i)=Gear_Ratio_MAPOp(4);
        end
end
n=v(i)*Gear_Ratio(i)*ig0/0.377/r;   %计算出每一工况点对应的发动机转速
%   定义相应的计算公式
  G=m*g;
  Fw=CdA*v(i).^2/21.15;
  Ff=G*f;
  q=1+Iw/(m*r^2)+If*Gear_Ratio(i).^2*ig0^2*nT/(m*r^2);
%   插值法求出特定时刻的燃油消耗率
  n1=[1000,1250,1500,1700,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,5250,5500];
  b0=[774.7352,737.7197,699.9319,666.9109,678.4390,666.7982,677.7000,688.4520,694.6049,696.9311,715.0548,796.5509,859.5787,929.7623,947.7568,1.0401];
  b1=[-203.4521,-136.9475,-98.3713,-75.0722,-65.3001,-54.9738,-51.3927,-47.8049,-43.1263,-39.3405,-37.7119,-39.9317,-40.6188,-40.8966,-42.4501,-0.0466] ;
  b2=[29.09,13.3650,7.3339,4.5257,3.2995,2.4101,2.0627,1.7742,1.4153,1.1760,1.0331,1.0085,0.9633,0.8902,0.9573,0.001];
  b3=[-1.7906,-0.5434,-0.2268,-0.1116,-0.0681,-0.0438,-0.0342,-0.0275,-0.0194,-0.0147,-0.0118,-0.0107,-0.0097,-0.0082,-0.0091,0];
  b4=[0.0402,0.0079,0.0025,0.0010,0.0005,0.0003,0.0002,0.0002,0.0001,0.0001,0,0,0,0,0,0];
  %   根据计算得出的发动机转速插值求出相应的特征参数
  B0=spline(n1,b0,n); B1=spline(n1,b1,n); B2=spline(n1,b2,n); B3=spline(n1,b3,n); B4=spline(n1,b4,n);   
  %根据整车的运动状态来定义油耗率的计算公式
  if  a(i) >0
      Pa(i)=(G*f*v(i)/3600+CdA*v(i).^3/76140+q*m*v(i).*a(i)/3600)/nT;
      b(i)=B0+B1.*Pa(i)+B2.*Pa(i).^2+B3.*Pa(i).^3+B4.*Pa(i).^4;
      Q(i)=Pa(i).*b(i)./(367.1*pg);
      disp(Q(i));
  elseif a(i) <0
      b(i)=0;
      Q(i)=0.1645;
      disp(Q(i));
  else
      if v(i)>0
       Pa(i)=(G*f*v(i)/3600+CdA*v(i).^3/76140)/nT;
      b(i)=B0+B1.*Pa(i)+B2.*Pa(i).^2+B3.*Pa(i).^3+B4.*Pa(i).^4;
      Q(i)=Pa(i).*b(i)./(367.1*pg);
      disp(Q(i));
      else
          b(i)=0;
    Q(i)=0.1645;
    disp(Q(i));
      end
  end
end