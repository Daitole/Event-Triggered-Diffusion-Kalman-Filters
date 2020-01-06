function [eita,P_next]=dif_ekf_p1(x,P,hmeas,Rl,yl)
% diffusion Kalman
%   Detailed explanation goes here

% pmin_p = [0.001; 0.001; 0.001];
% pmin_o = 1e-13;
% pmin_b = 0.4;
% Pmin_vec = [0;0;0;0;0];
% for i=2:length(node_ids)
%     Pmin_vec = [Pmin_vec; [pmin_p; pmin_o; pmin_b]];
% end
% Pmin = diag(Pmin_vec);
%Rl=H_cap*P*transpose(H_cap)+Rl;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%try without inverse
% Re =0;
% for i=1:length( Rl)
%     [ h, H_cap]= jaccsd(hmeas{i},x);
%    Re = Re + Rl{i} + H_cap*P*conj(H_cap)';
% end

% sum =0;
% for i=1:length( Rl)
%     [ h, H_cap]= jaccsd(hmeas{i},x); 
%     Re = Rl{i} + H_cap*P*conj(H_cap)';
%     P = P - P*conj(H_cap)'*( Re^-1)*H_cap*P;
% end
% P_next = P ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P_minus = P;
sum=0;
for i=1:length( Rl)
   [ h, H_cap]= jaccsd(hmeas{i},x); 
  sum = sum + conj(H_cap)'*( Rl{i}^-1)*H_cap;
end
sum = sum + (P)^-1 ;
P_next=(sum)^-1;
%%or for scalar R i.e Rij or Dij
%% avoid matrix inversion by using Sherman Morrison 

% Q = P;
% for i=1:length( Rl)
%      [ h, H_cap]= jaccsd(hmeas{i},x);  
%  Q= Q - (Q*H_cap'*Rl{i}^-1*H_cap*Q)/((1+H_cap*Q*Rl{i}^-1*H_cap')) ;  
% end
% P_next=Q;
%%or
%% avoid matrix inversion by using Woodbury matrix identity
% for i=1:length( Rl)
%       [ h, H_cap]= jaccsd(hmeas{i},x);
%       P = P - P*H_cap'*( Rl{i} + H_cap*P*H_cap')^-1 * H_cap*P;
%    %P = P - P *H_cap'*Rl{i}^-1* ( Rl{i}^-1 + Rl{i}^-1*H_cap*P*H_cap'*Rl{i}^-1)^-1 *Rl{i}^-1*H_cap*P;
%   %Binomial inverse theorem
%   %P = P - P *H_cap'*((eye(length(Rl{i}))+ Rl{i}^-1 *H_cap*P*H_cap')^-1)*Rl{i}^-1*H_cap*P;
% end
% P_next = P;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- eita
sum=0;
for i=1:length( Rl)
        [ h, H_cap]= jaccsd(hmeas{i},x);
  sum = sum + conj(H_cap)'*Rl{i}^(-1)*( yl{i} - h);
end
eita = P_next*sum + x;

% %-- Diffusion update
% x = eita;
% %-- Time update
% [f F_bar]= jaccsd(fstate,x);
% u = f - F_bar*x;
% x_next = F_bar*x + u;
% P_next = F_bar*P_next*transpose(F_bar) + G*Q*transpose(G);

end

function [z,A]=jaccsd(fun,x)
% JACCSD Jacobian through complex step differentiation
% [z J] = jaccsd(f,x) 
% z = f(x)
% J = f'(x)
% example :
% f=@(x)[x(2);x(3);0.05*x(1)*x(2)];
% [x,A]=jaccsd(f,[1 1 1])
% 
% x =
% 
%     1.0000
%     1.0000
%     0.0500
% 
% 
% A =
% 
%          0    1.0000         0
%          0         0    1.0000
%     0.0500    0.0500         0
z=fun(x);
n=numel(x);%Number of elements in an array or subscripted array expression.
m=numel(z);
A=zeros(m,n);
h=n*eps;
for k=1:n
    x1=x;
    x1(k)=x1(k)+h*i;
    A(:,k)=imag(fun(x1))/h;
end
end