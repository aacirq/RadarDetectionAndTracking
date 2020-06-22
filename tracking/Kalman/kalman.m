function [X_next, P_next, K] = kalman(Z, Xkk, Pkk, F, G, H, Q, R)
    % ¿¨¶ûÂüÂË²¨-µü´úÒ»²½
    X_predict = F * Xkk;
    P_predict = F * Pkk * F' + G * Q * G';

    S = H * P_predict * H' + R;
    K = P_predict * H' / S;
    X_next = X_predict + K * (Z - H * X_predict);
    P_next = P_predict - K * H * P_predict;
end