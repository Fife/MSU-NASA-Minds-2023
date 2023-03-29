%Checkerboard Scanning

FieldLength = 10;
chunkSize = 5;
centerCoord = [0,0];

chunk = TellusTest(FieldLength,FieldLength,chunkSize,centerCoord);
path =
x = chunk(1:2:end);
y = chunk(2:2:end);

scatter(x,y)

