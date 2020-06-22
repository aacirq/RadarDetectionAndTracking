function [R] = get_R(p, p0, sigma_rho, sigma_theta)
    delta_p = p - p0;
    [theta, rho] = cart2pol(delta_p(1), delta_p(2));
    A = [cos(theta),  -rho * sin(theta); ...
         sin(theta),  rho * cos(theta)];
    tmp = [sigma_rho ^ 2,  0; ...
           0,              sigma_theta ^ 2];
    R = A * tmp * A';