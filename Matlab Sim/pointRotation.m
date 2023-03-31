
function output = pointRotation(point, angle)
    % Create rotation matrix
    point = [point(1);point(2)];
    theta = angle; % to rotate 90 counterclockwise
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    % Rotate your point(s)
    output = R*point;
end
