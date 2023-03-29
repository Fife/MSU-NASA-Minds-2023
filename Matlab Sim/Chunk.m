function chunkList = Chunk(xLength, yLength, numSqr, center)
    chunkList = [];
    x = xLength/numSqr;
    y = yLength/numSqr;
    offX = center(1)-(0.5*xLength);
    offY = center(2)-(0.5*yLength); 

    for j = 0:numSqr-1
        for i = 0:numSqr-1
            tl = [offX + (x*i), offY + (y*(j+1))];
            bl = [(x*i) + offX, (y*(j))+offY];

            tr = [(x*(i+1)) + offX, (y*(j+1))+offY];
            br = [(x*(i+1)) + offX, (y*(j))+offY];
            


            chunkList = [chunkList, {bl, tl, tr, br}];
        end
    end
end 