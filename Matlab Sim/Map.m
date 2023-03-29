classdef Map
    %ummary of this class goes here
    %   Detailed explanation goes here

    properties
        chunkLen
        field
        fieldStatus

        targetList
        targetIndex
        target

        currentSquare
        squareIndex

    end

    methods
        function obj = untitled10(inputArg1,inputArg2)
            %UNTITLED10 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end