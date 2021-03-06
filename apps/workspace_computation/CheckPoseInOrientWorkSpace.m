function [out] = CheckPoseInOrientWorkSpace(cdpr_p,cdpr_v,tau_lim,out,pose,varargin)

if (~isempty(varargin))
    rec = varargin{1};
end
%options = optimoptions('linprog','Display','none');
cdpr_v = UpdateIKZeroOrd(pose(1:3),pose(4:end),cdpr_p,cdpr_v);
cdpr_v = CalcExternalLoads(cdpr_v,cdpr_p);
cdpr_v = CalcCablesStaticTension(cdpr_v);

if ((~any(isnan(cdpr_v.tension_vector))) && isempty(cdpr_v.tension_vector(cdpr_v.tension_vector>tau_lim(2)))...
        && isempty(cdpr_v.tension_vector(cdpr_v.tension_vector<tau_lim(1))))
    out.counter = out.counter+1;
    out.pose(:,out.counter) = pose;
    out.position(:,out.counter) = out.pose(1:3,out.counter);
    out.ang_par(:,out.counter) = out.pose(4:end,out.counter);
    out.rot_mat(:,:,out.counter) = cdpr_v.platform.rot_mat;
    out.tension_vector(:,out.counter) = cdpr_v.tension_vector;
    K = MyInv(cdpr_v.geometric_jacobian);
%     out.manip(1,out.counter) = norm(K(4:6,:),Inf);
    
    Kr = cdpr_v.geometric_jacobian(:,4:6);
    Kp = cdpr_v.geometric_jacobian(:,1:3);
    Pp = eye(6)-Kp*MyInv(Kp'*Kp)*Kp';
    out.manip(1,out.counter) = sqrt(norm(inv(Kr'*Pp*Kr),2));
%     L = [cdpr_v.geometric_jacobian' -cdpr_v.geometric_jacobian']';
%     for ii = 1:3
%         v = zeros(6,1); v(ii+3) = 1;
%         [~,fval(ii)] =  linprog(-v,L,ones(length(L),1),[],[],[],[],options);
%         fval(ii) = -fval(ii);
%     end
%     out.manip3(1,out.counter) = max(fval);
end

end