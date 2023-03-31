function travel_path = GeneratePath(bottom_left, length, width, offset)
    bottom_left = cell2mat(bottom_left);
    x = bottom_left(1)+offset;
    y = bottom_left(2)+offset;
    travel_path = [x, y];
    for i = 1:(length/(2*width))+1
        x = x + length;
        travel_path = [travel_path, [x, y]];
        y = y + width;
        travel_path = [travel_path, [x, y]];
 		x = x - length;
        travel_path = [travel_path, [x, y]];
 		y = y + width;
        travel_path = [travel_path, [x, y]];
    end
	x = x + length;
	travel_path = [travel_path, [x, y]];

    for i = 1:(length/(2*width)) +1 
     	y = y - length;
 		travel_path = [travel_path, [x, y]];
 		x = x - width;
 		travel_path = [travel_path, [x, y]];		
        y = y + length;
 		travel_path = [travel_path, [x, y]];
 		x = x - width;
 		travel_path = [travel_path, [x, y]];
    end
 	y = y - length;
 	travel_path = [travel_path, [x, y]];
end