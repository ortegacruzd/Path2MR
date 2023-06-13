% [Gmodule GX GY]=grad2d(X)
% Gradient for 2D images
function [Gmodule GX GZ]=grad2d(X)

X = double(X);

v=[-1 0 1];

GX=imfilter(X,reshape(v,[3 1]));
GY=imfilter(X,reshape(v,[1 3]));

GX(1,:,:)=X(2,:,:)-X(1,:,:); GX(end,:,:)=X(end,:,:)-X(end-1,:,:);
GY(:,1,:)=X(:,2,:)-X(:,1,:); GY(:,end,:)=X(:,end,:)-X(:,end-1,:);

Gmodule=sqrt(GX.*GX+GY.*GY);