scanRate = 1/100;
velocity = 5; 
distance_per_step = scanRate*velocity;

path = GeneratePath([0,0], 1, 0.25, 0);
pathIndex = 1;

current_coord = [0,0];

data= [];
while pathIndex < length(path)
    distance_to_point = sqrt((path(pathIndex)-current_coord(1))^2 + (path(pathIndex+1)-current_coord(2))^2);
    if distance_to_point < 0.01
        pathIndex = pathIndex + 2;
    else
        traj = ([path(pathIndex), path(pathIndex+1)]  - current_coord);
        utraj = traj/(norm(traj));

        distance_step = distance_per_step*utraj;
        current_coord = current_coord + distance_step;
        data = [data, {current_coord}]
        
    end
end

for i = 1 : length(data)
    hold on
        scatter(data{1,i}(1), data{1,i}(2))
    hold off
end
