function A = wathen(nx, ny, k, classname)
%WATHEN Wathen matrix (sparse).
%   A = GALLERY('WATHEN',NX,NY) is a sparse matrix with random
%   elements. It is an N-by-N finite element matrix, where
%       N = 3*NX*NY + 2*NX + 2*NY + 1.
%   A is precisely the "consistent mass matrix" for a regular NX-by-NY
%   grid of 8-node elements in two space dimensions. A is symmetric
%   positive definite for any (positive) values of the "density",
%   RHO(NX,NY), which is chosen randomly. In particular, if
%   D = DIAG(DIAG(A)), then 0.25 <= EIG(INV(D)*A) <= 4.5, for any
%   positive integers NX and NY and any densities RHO(NX,NY).
%
%   B = GALLERY('WATHEN',NX,NY,1) returns B = DIAG(DIAG(A)) \ A,
%   which is A row-scaled to have unit diagonal.

%   Reference:
%   A. J. Wathen, Realistic eigenvalue bounds for the Galerkin
%   mass matrix, IMA J. Numer. Anal., 7 (1987), pp. 449-457.
%
%   Nicholas J. Higham
%   Revised by Tim Davis.
%   Copyright 1984-2007 The MathWorks, Inc.

if isempty(ny)
  error(message('MATLAB:wathen:NotEnoughInputs'))
end
if isempty(k), k = 0; end

e1 = [6 -6 2 -8;-6 32 -6 20;2 -6 6 -6;-8 20 -6 32];
e2 = [3 -8 2 -6;-8 16 -8 20;2 -8 3 -8;-6 20 -8 16];
e = [e1 e2; e2' e1]/45;
n = 3*nx*ny+2*nx+2*ny+1;
ntriplets = nx*ny*64 ;
I = zeros (ntriplets, 1) ;
J = zeros (ntriplets, 1) ;
X = zeros (ntriplets, 1) ;
ntriplets = 0 ;

RHO = 100*rand(nx,ny);
nn = zeros(8,1);

 for j=1:ny
     for i=1:nx

      nn(1) = 3*j*nx+2*i+2*j+1;
      nn(2) = nn(1)-1;
      nn(3) = nn(2)-1;
      nn(4) = (3*j-1)*nx+2*j+i-1;
      nn(5) = 3*(j-1)*nx+2*i+2*j-3;
      nn(6) = nn(5)+1;
      nn(7) = nn(6)+1;
      nn(8) = nn(4)+1;

      em = e*RHO(i,j);

         for krow=1:8
             for kcol=1:8
                 ntriplets = ntriplets + 1 ;
                 I (ntriplets) = nn (krow) ;
                 J (ntriplets) = nn (kcol) ;
                 X (ntriplets) = em (krow,kcol) ;
             end
         end

      end
  end

A = sparse (I,J,X,n,n) ;
if k == 1
   A = diag(diag(A)) \ A;
end
