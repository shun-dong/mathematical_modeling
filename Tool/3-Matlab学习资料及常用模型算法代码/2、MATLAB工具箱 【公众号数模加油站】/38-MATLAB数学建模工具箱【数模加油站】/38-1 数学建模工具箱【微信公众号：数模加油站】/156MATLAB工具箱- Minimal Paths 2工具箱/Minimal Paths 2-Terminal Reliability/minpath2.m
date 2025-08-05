% Author: Mohammad Javanbarg
% Please cite as follows: 
% 1)
% ASCE, Technical Council on Lifeline Earthquake Engineering Conference (TCLEE) 2009
% M. B. Javanbarg ; C. Scawthorn ; J. Kiyono ; and Y. Ono, "Minimal Path Sets Seismic Reliability Evaluation of Lifeline Networks with Link and Node Failures".

% http://ascelibrary.org/doi/abs/10.1061/41050(357)105

% 2)% ASCE, Technical Council on Lifeline Earthquake Engineering Conference (TCLEE) 2009
% M. B. Javanbarg ; C. Scawthorn ; J. Kiyono ; and Y. Ono, "Multi-Hazard Reliability Analysis of Lifeline Networks".

% http://ascelibrary.org/doi/abs/10.1061/41050%28357%29106 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function R1=minpath2(A,bbb,p,L)
%R1=minpath2_edit(V,E,bbb,p,L)
%
% Minimal Pathsets Relaibility Analysis of a Digraph 
% Applicable: Source-Distination Terminal Reliability of General Networks
% 
% Mohammad B. Javanbarg, Dept. of Urban Management
% Kyoto University, Dec. 2008
%================================================================================================================================
tic;
   
% Display network topology

disp('The grBase test')
        
    grPlot(V,E,'d','%d','');
     title('\bfThe initial digraph')
     BG=grBase(E);
     disp('The bases of digraph:')
     disp(' N    vertexes')
for k1=1:size(BG,1),
      fprintf('%2.0f    ',k1)
      fprintf('%d  ',BG(k1,:))
      fprintf('\n')
end

%===============================================================================================================================
% Adjacency matrix
[rA,cA]=size(A);
jA=0;
for iA=1:rA*cA
    if A(iA)==1
        jA=jA+1;
    end
end    
% A = adjMat(V,E)
A = sparse(A);

%===============================================================================================================================
% Branch matrix

B=zeros(length(A),1);
B(1:length(B))=1:length(B);
for i=1:length(A)
    ps{i}=[parents(A, i)];
    col=max(length(ps{i}));
    B(i,2:col+1)=[ps{i}];
end
[rowB colB]=size(B);
B(:,colB+1)=0;
B=sparse(B);
% 
%===============================================================================================================================
% Path Matrix 

% Initialize the path

[sizeX sizeY] = size(B);
path = zeros(1,sizeX+1);
flag = 1;
path_y = 1;
path_x = 1;
mark_y = 2*ones(1, sizeX+1);
target = sizeX;

while(flag) 
   path(path_y) = target;
   path_y = path_y + 1;
   if ( B(target, mark_y(target)) == 0) 
      if (target == sizeX) 
            flag = 0;
            break;
      end
      if (mark_y(target) == 2)
         point = path(path_y-2);
         if ( B(point,mark_y(point)) == 0)
            mark_y(point) = 2;
         end
      else
         mark_y(path(path_y-1)) = 2;
         path_x = path_x - 1;
      end 
      path_y = 1;
      target = path(path_y);
    
      for i=1:sizeX
         NP(path_x, i) = path(i);
         path(i) = 0;
         if (path(i+1) == 0)
            break;
         end
      end
      path_x = path_x + 1;
      
      for count=1:sizeX+1
         if (mark_y(count) ~= 2)
            break;
         end
      end
      if (count < sizeX+1)
         for j=count+1:sizeX
            if (mark_y(j) > 2)
               mark_y(j) = mark_y(j) - 1;
            end
         end
      end
   else
      tmp = B(target, mark_y(target));
      mark_y(target) = mark_y(target) + 1;
      target = tmp;
   end   
end
%Minimal pathsets for nodes
NP;
toc
t = toc

%===============================================================================================================================
% Node pathsets: binary

[a b]=size(NP);
nodepathset=zeros(a,length(A));
for i=1:a
    for j=1:length(A)
        rowp{i}=[NP(i,:)];
        nodepathset(i,j)=~isempty(find(rowp{i}==j));
    end
end
nodepathset;

% ==============================================================================================================================
% Adjacency matrix with respect to link number
 
[i,j,v]=find(A);
[h g]=size(A);

m=1;
for m=1:length(v)
    vv(m)=m;
    m=m+1;
end

A_link= sparse(i,j,vv,h,g);

% ================================================================================================================================
% Path matrix for link

NP_rev=NP(:,end:-1:1,:);
[x y]=size(NP_rev);

for k=1:x
    for j=1:y-1
        if NP_rev(k,j)==0
           LP(k,j)=0;
        else
         LP(k,j)=A_link(NP_rev(k,j),NP_rev(k,j+1));
        end
    end
end

% Minimal pathsets for links
%LP; 

% clear A NP NP_rev A_link NP 

%===============================================================================================================================
% Link pathsets: binary
%
[a b]=size(LP);
PM=zeros(a,max(vv));

for i=1:a
    for j=1:max(vv)
        rowlp{i}=[LP(i,:)];
     PM(i,j)=~isempty(find(rowlp{i}==j));
    end
end
MMPV=PM;

[u v]=size(MMPV);

%A = [1:length(E)];
A = [1:jA];

%===============================================================================================================================
% state space vector 

%  b = {[0 1],[0 1],[0 1],[0 1],[0 1],[0 1],[0 1],[0 1]};   
b=bbb;
s=1;
while ( s<=L )
    Q(s)=0;
    r=0;
    i=1;
    t=1;
    while ( i<=length(A) )
        j=1;
        l=length(b{i});
        r=rand;
        if ( p{i}(j)>r )
            x(i)=b{i}(j);
            j=l+1;
        else
            j=j+1;
        end
        while ( j<=l )
            if ( sum(p{i}(1:j-1))<r | r<=sum(p{i}(1:j)) )
                x(i)=b{i}(j);
                j=l+1;
            else
                j=j+1;
            end
        end
        i=i+1;
    end
    X{s} = x;
    while ( t<=u )
        if ( X{s}>= MMPV(t,:) )
            Q(s)=1;
            t=u+1;
        else
            t=t+1;
        end
    end
     %Q=Q+Q(s)
     s=s+1;
end
Q;
R1=sum(Q)/L;
%R2=1-(sum(Q)/L)

% Minimal Pathsets Two-Terminal Reliability
toc;
t = toc;

