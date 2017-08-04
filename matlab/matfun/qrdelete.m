function [Q,R] = qrdelete(Q,R,j,orient)
%QRDELETE Delete a column or row from QR factorization.
%   [Q1,R1] = QRDELETE(Q,R,J) returns the QR factorization of the matrix A1,
%   where A1 is A with the column A(:,J) removed and [Q,R] = QR(A) is the QR
%   factorization of A. Matrices Q and R can also be generated by 
%   the "economy size" QR factorization [Q,R] = QR(A,0). 
%
%   QRDELETE(Q,R,J,'col') is the same as QRDELETE(Q,R,J).
%
%   [Q1,R1] = QRDELETE(Q,R,J,'row') returns the QR factorization of the matrix
%   A1, where A1 is A with the row A(J,:) removed and [Q,R] = QR(A) is the QR
%   factorization of A.
%
%   Example:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3;
%      [Q1,R1] = qrdelete(Q,R,j,'row');
%   returns a valid QR factorization, although possibly different from
%      A2 = A;  A2(j,:) = [];
%      [Q2,R2] = qr(A2);
%
%   Class support for inputs Q,R:
%      float: double, single
%
%   See also QR, QRINSERT, PLANEROT.

%   Copyright 1984-2004 The MathWorks, Inc. 

if nargin < 4
    if nargin < 3
        error(message('MATLAB:qrdelete:NotEnoughInputs'))
    end
    orient = 'col';
end

[mq,nq] = size(Q);
[m,n] = size(R);
if ~strcmp(orient,'col') && (mq ~= nq)
    error(message('MATLAB:qrdelete:QNotSquare'))
elseif (nq ~= m)
    error(message('MATLAB:qrdelete:InnerDimQRfactors'))
elseif j <= 0
    error(message('MATLAB:qrdelete:NegDeletionIndex'))
end

switch orient
case 'col'
    if (j > n)
        error(message('MATLAB:qrdelete:InvalidDelIndex'))
    end
    % Remove the j-th column.  n = number of columns in modified R.
    R(:,j) = [];
    [m,n] = size(R);

    % R now has nonzeros below the diagonal in columns j through n.
    %    R = [x | x x x         [x x x x
    %         0 | x x x          0 * * x
    %         0 | + x x    G     0 0 * *
    %         0 | 0 + x   --->   0 0 0 *
    %         0 | 0 0 +          0 0 0 0
    %         0 | 0 0 0]         0 0 0 0]
    % Use Givens rotations to zero the +'s, one at a time, from left to right.
    
    for k = j:min(n,m-1)
        p = k:k+1;
        [G,R(p,k)] = planerot(R(p,k));
        if k < n
            R(p,k+1:n) = G*R(p,k+1:n);
        end
        Q(:,p) = Q(:,p)*G';
    end
    % If Q is not square, Q is from economy size QR(A,0).
    % Both Q and R need further adjustments.
    if (mq ~= nq) 
        R(m,:)=[];
        Q(:,nq)=[];
    end
    
case 'row'
    if (j > m)
        error(message('MATLAB:qrdelete:InvalidDelIndex'))
    end
    % This permutes row j of Q*R to row 1 of Q(p,:)*R
    if j ~= 1
        p = [j, 1:j-1, j+1:m];
        Q = Q(p,:);
    end
    q = Q(1,:)';
    
    % q is the transpose of the first row of Q.
    %    q = [x         [1
    %         -          -
    %         +    G     0
    %         +   --->   0
    %         +          0
    %         +          0
    %         +]         0]
    %
    % Use Givens rotations to zero the +'s, one at a time, from bottom to top.
    % The result will have a "1" in the first entry.
    %
    % Apply the same rotations to R, which becomes upper Hessenberg.
    %    R = [x x x x          [* * * *
    %         -------           -------
    %           x x x     G     * * * *
    %             x x    --->     * * *
    %               x               * *
    %         0 0 0 0                 *
    %         0 0 0 0]          0 0 0 0]
    %
    % Under (the transpose of) the same rotations, Q becomes
    %    Q = [x | x x x x x         [1 | 0 0 0 0 0
    %         --|----------          --|----------
    %         x | x x x x x    G'    0 | * * * * *
    %         x | x x x x x   --->   0 | * * * * *
    %         x | x x x x x          0 | * * * * *
    %         x | x x x x x          0 | * * * * *
    %         x | x x x x x]         0 | * * * * *]
    
    for i = m : -1 : 2
        p = i-1 : i;
        [G,q(p)] = planerot(q(p));
        R(p,i-1:n) = G * R(p,i-1:n);
        Q(:,p) = Q(:,p) * G';
    end
    
    % The boxed off (---) parts of Q and R are the desired factors.
    Q = Q(2:end,2:end);
    R(1,:) = [];
    
otherwise
    error(message('MATLAB:qrdelete:InvalidInput4'));
end
