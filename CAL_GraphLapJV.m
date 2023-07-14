% Common Algorithm Lib
% CAL_GraphLapJV
% Algorithm for graph matching (only linear term is considered) 
% Solve linear assignment problem of graph matching by R. Jonker and A. Volgenant's method
% Input:
%     cost: n1 * n2 cost matrix
% Output:
%     idx_x: n1 * 1, matching idx
%     idx_y: n2 * 1, matching idx
%         h: scalar, total cost
% Problem statement
%   for cost matrix cost(i,j), find association matrix f so that
%     f = argmin sum(sum(cost(i,j) * f(i,j)))
%     s.t.
% 			f(i,j) = {0, 1}
% 			sum(f(i,:)) = 1, sum(f(:,j)) = 1, for any i,j
%
% Reference: R. Jonker and A. Volgenant, "A shortest augmenting path algorithm for dense and sparse linear
% assignment problems", 1987
function [x, y, h] = CAL_GraphLapJV(cost)

%     cost = [
%             0.1 0.8 1.2;
%             1.0 1.2 0.1;
%             0.5 0.3 0.9;
%          ];
        
    n1 = size(cost, 1);
    n2 = size(cost, 2);
    n = max(n1, n2);
    
    % x: columns assgined to rows
    % y: rows assigned to columns
    x = zeros(n1, 1);    
    y = zeros(n2, 1);    
    h = inf;

    % Record invalid edges (marked as Inf)
    bInf = isinf(cost);
    MaxCost = max(cost(~bInf)) + eps * 10;
    if(isempty(MaxCost))
        return;
    end;    
    cost(bInf) = MaxCost;
    
    % Add additional padding elements in cost matrix when n1 ~= n2
    bTrans = 0;
    if(n1 > n2)
        cost(:, n2 + 1:n) = MaxCost;
    elseif(n1 < n2)
        cost(n1 + 1:n, :) = MaxCost;
        cost = cost';
        bTrans = 1;
    end;    
    
    % x: columns assgined to rows
    % y: rows assigned to columns
    x = zeros(n, 1);    
    y = zeros(n, 1);    
    u = zeros(n, 1);    
    v = zeros(n, 1);    
    
    % Column reduction
    for j = n:-1:1
        col(j) = j;
        
        [h, i1] = min(cost(:, j));
        v(j) = h;
        
        if(x(i1) == 0)
            x(i1) = j;
            y(j) = i1;
        else                        % conflicting candidate
            x(i1) = -abs(x(i1));
            y(j) = 0;
        end;        
    end;
    
    nf = 0;
    fr = zeros(n, 1);
    for i = 1:n
        if(x(i) == 0)               % free item
            nf = nf + 1;
            fr(nf) = i;
        elseif(x(i) < 0)            % conflicting item
            x(i) = -x(i);
        else                        % matched item
            j1 = x(i);
            
            c_min = min(cost(i, :) - v(:)');            
%             c_min = inf;
%             for j = 1:n
%                 if(j == j1)
%                     continue;
%                 end;  
%                 
%                 if((cost(i, j) - v(j)) < c_min)
%                     c_min = cost(i, j) - v(j);
%                 end;
%             end;

            v(j1) = v(j1) - c_min;
        end;
    end;
    
    cnt = 0;    
    count = 0;
    while(true)        
        k = 1;
        nf0 = nf;
        nf = 0;
        
        while(k <= nf0)
            i = fr(k);
            k = k + 1;
            u1 = cost(i, 1) - v(1);
            j1 = 1;
            u2 = inf;
            for j = 2:n
                h = cost(i, j) - v(j);
                if(h < u2)
                    if(h >= u1)
                        u2 = h;
                        j2 = j;
                    else
                        u2 = u1;
                        u1 = h;
                        j2 = j1;
                        j1 = j;
                    end;                    
                end;
            end;
            
            i1 = y(j1);
            if(u1 < u2)
                v(j1) = v(j1) - u2 + u1;
            elseif(i1 > 0)
                j1 = j2;
                i1 = y(j1);
            end;
            
            if(i1 > 0)
                if(u1 < u2)
                    k = k - 1;
                    fr(k) = i1;
                else
                    nf = nf + 1;
                    fr(nf) = i1;
                end;
            end;
            x(i) = j1;
            y(j1) = i;     
            
            count = count + 1;
            
%             % Debug code
%             disp(sprintf('cnt = %d, k = %d, nf0 = %d, i1 = %2d, u1 = %.16f, u2 = %.16f', cnt, k, nf0, i1, u1, u2));

            if(count > 3000)
                disp('Iteration reached 3000 times! exit CAL_GraphLapJV.');
                break;
            end;
        end;        
        
        cnt = cnt + 1;
        if(cnt == 2)                % routine applied twice
            break;
        end;
    end; % while(true)    
    
    nf0 = nf;
    for nf = 1:nf0
        
        % Initialize d & pred array
        i1 = fr(nf);
        low = 1;
        up  = 1;
        for j = 1:n
            d(j) = cost(i1, j) - v(j);
            pred(j) = i1;
        end;
        
        bFinished = 0;
        while(true)
            
            if(up == low)
                last = low - 1;
                c_min = d(col(up));
                up = up + 1;
                for k = up:n
                    j = col(k);
                    h = d(j);
                    if(h <= c_min)
                        if(h < c_min)
                            up = low;
                            c_min = h;
                        end;
                        col(k) = col(up);
                        col(up) = j;
                        up = up + 1;                        
                    end;
                end;
                
                for h = low:up - 1
                    j = col(h);
                    if(y(j) == 0)
                        bFinished = 1;
                        break;
                    end;
                end;
                
                if(bFinished)
                    break;
                end;
            end; % if(up == low)
            
            j1 = col(low);
            low = low + 1;
            i = y(j1);
            u1 = cost(i, j1) - v(j1) - c_min;
            for k = up:n
                j = col(k);
                h = cost(i,j) - v(j) - u1;
                if(h < d(j))
                    d(j) = h;
                    pred(j) = i;
                    if(h == c_min)
                        if(y(j) == 0)
                            bFinished = 1;
                            break;
                        else
                            col(k) = col(up);
                            col(up) = j;
                            up = up + 1;
                        end;
                    end;
                end;
            end;

            if(bFinished)
                break;
            end;
            
        end; % while(true)
        
        % Updating of cloumn prices
        for k = 1:last
            j1 = col(k);
            v(j1) = v(j1) + d(j1) - c_min;
        end;    
        
	    while(true)
	        i = pred(j);
	        y(j) = i;
	        
	        k = j;
	        j = x(i);
	        x(i) = k;
	        if(i == i1)
	            break;
	        end;        
	    end;      
        
    end; % for nf = 1:nf0    
    
    nr = min(n1, n2);
    x(x > nr) = 0;
    y(nr + 1:end) = [];
    
    % Compute optimal cost
    h = 0;
    for i = 1:n
        j = x(i);
        if(j == 0)
            continue;
        end;
        
        u(i) = cost(i, j) - v(j);
        h = h + u(i) + v(j);
    end;
    
    if(bTrans)
        t = x;
        x = y;
        y = t;                
    end;
    
    % Remove invalid(Inf) related matches
    Matching = zeros(n1, n2);
    for ix = 1:n1
        if(x(ix) > 0)            
            Matching(ix, x(ix)) = 1;
            if(bInf(ix, x(ix)))
                x(ix) = 0;
            end;
        end;        
    end;

    for iy = 1:n2
        if(y(iy) > 0)            
            Matching(y(iy), iy) = 1;
            if(bInf(y(iy), iy))
                y(iy) = 0;
            end;
        end;        
    end;
    
    h = h - sum(cost(Matching & bInf));
