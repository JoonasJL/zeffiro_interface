function [x,y,z] = zef_3by3_solver(a,b,c,d)

D = a(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2)) ...
    - b(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2)) ...
    + c(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

D_x =  d(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2)) ...
    - b(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2)) ...
    + c(:,1).*(d(:,2).*b(:,3) - d(:,3).*b(:,2));

D_y = a(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2)) ...
    - d(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2)) ...
    + c(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2));

D_z = a(:,1).*(b(:,2).*d(:,3) - b(:,3).*d(:,2)) ...
    - b(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2)) ...
    + d(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

x = D_x./D;
y = D_y./D;
z = D_z./D;

end