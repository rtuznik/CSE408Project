%Calculate the best spot at different number of rolls
%Calculate the a factor with prbability, income, and cost
%Figure out why orange isn't higher
part1 = 4; %1, 2, 3, or 4
part2 = 1; %1 or 2
part4 = 2; %1 or 2
%Part 1: Create Transition Matrix (normalization will be done all at the
%same time)
numberOfSpaces = 40;
B = zeros(numberOfSpaces, numberOfSpaces);
doubleDiceRollDistribution = [0 1/36 2/36 3/36 4/36 5/36 6/36 5/36 4/36 3/36 2/36 1/36]; %For 1 to 12

%1.1: All spaces do nothing
if(part1 == 1)
    for i=1:size(B,2)
        if(i < 40)
            B(i + 1:min(numberOfSpaces, i + 12), i) = doubleDiceRollDistribution(1:min(12, numberOfSpaces - i));
        end
        if(i >= 29) %At this point, we need to circle back to the start
            B(1:(12 - min(12, numberOfSpaces - i)), i) = doubleDiceRollDistribution(min(11, numberOfSpaces - i) + 1:12); 
        end
    end
end

%1.2: All spaces do nothing + triple roll sends to jail
if(part1 == 2)
    for i=1:size(B,2)
        if(i < 40)
            B(i + 1:min(numberOfSpaces, i + 12), i) = doubleDiceRollDistribution(1:min(12, numberOfSpaces - i));
        end
        if(i >= 29) %At this point, we need to circle back to the start
            B(1:(12 - min(12, numberOfSpaces - i)), i) = doubleDiceRollDistribution(min(11, numberOfSpaces - i) + 1:12); 
        end
        %Roll a double three times in a row (ignoring the case where you
        %roll doubles a third time to calculate utility cost for the chance
        %card in which you move to the nearest utility).
        %Since technically we would need to simulate three rolls to
        %compute this (would require manually computing 40 probabilities for all 40 spaces),
        %we will only be computing a simplified estimation
        tripleRollProbability = (6/36)^3; %There are 6 ways to roll a double. And it had to have been done 3 times
        B(:, i) = B(:, i) * (1 - tripleRollProbability);
        B(11, i) = B(11, i) + tripleRollProbability;
    end
end

%1.3: All spaces except Go to jail do nothing. Note that starting on jail
%sends you straight to jail
if(part1 == 3)
   for i=1:size(B,2)
        if(i < 40)
            B(i + 1:min(numberOfSpaces, i + 12), i) = doubleDiceRollDistribution(1:min(12, numberOfSpaces - i));
        end
        if(i >= 29) %At this point, we need to circle back to the start
            B(1:(12 - min(12, numberOfSpaces - i)), i) = doubleDiceRollDistribution(min(11, numberOfSpaces - i) + 1:12);
        end
        %Roll a double three times in a row
        tripleRollProbability = (6/36)^3;
        B(:, i) = B(:, i) * (1 - tripleRollProbability);
        B(11, i) = B(11, i) + tripleRollProbability;

        if (i == 31) %Go to jail
            B(:, i) = 0;
            B(11, i) = 1;
        end
   end
end

%1.4: Add in chance and community chest
if(part1 == 4)
    for i=1:size(B,2)          
        if(i < 40)
            B(i + 1:min(numberOfSpaces, i + 12), i) = doubleDiceRollDistribution(1:min(12, numberOfSpaces - i));
        end
        if(i >= 29) %At this point, we need to circle back to the start
            B(1:(12 - min(12, numberOfSpaces - i)), i) = doubleDiceRollDistribution(min(11, numberOfSpaces - i) + 1:12);
        end
        
        %Roll a double three times in a row
        tripleRollProbability = (6/36)^3;
        B(:, i) = B(:, i) * (1 - tripleRollProbability);
        B(11, i) = B(11, i) + tripleRollProbability;
        
        if (i == 31) %Go to jail
            B(:, i) = 0;
            B(11, i) = 1;
        end
        if (i == 3 || i == 18 || i == 34) %Community Chest
            %Community Chest possibilities: No movement: 15/17, Go (1): 1/17,
            %Jail (11): 1/17
            
            %Multiply by the chance of actually moving from this space
            B(:, i) = B(:, i) * 15/17;
            
            %Now add the probabilities of the card movements
            B(1, i) = B(1, i) + 1/17;
            B(11, i) = B(11, i) + 1/17;
        end
        if (i == 8 || i == 23 || i == 37) %Chance
            %Chance possibilities: No movement: 7/16, Go (1): 1/16, Illinois Avenue (25): 1/16, St
            %Charles Place (12): 1/16, Nearest utility: 1/16, Nearest railroad:
            %1/16, Back 3 spaces, Jail (11): 1/16, Reading railroad (6): 1/16, Boardwalk (40):
            %1/16
            nearestUtility = 0;
            nearestRailroad = 0;
            if (i == 8)
                nearestUtility = 13;
                nearestRailroad = 6;
            end
            if (i == 23)
                nearestUtility = 29;
                nearestRailroad = 26;
            end
            if (i == 37)
                nearestUtility = 29;
                nearestRailroad = 36;
            end
            
            %Multiply by the chance of actually moving from this space
            B(:, i) = B(:, i) * 7/16;
            
            %Now add the probabilities of the card movements
            B(1, i) = B(1, i) + 1/16;
            B(25, i) = B(25, i) + 1/16;
            B(12, i) = B(12, i) + 1/16;
            B(nearestUtility, i) = B(nearestUtility, i) + 1/16;
            B(nearestRailroad, i) = B(nearestRailroad, i) + 1/16;
            B(i - 3, i) = B(i - 3, i) + 1/16;
            B(11, i) = B(11, i) + 1/16;
            B(6, i) = B(6, i) + 1/16;
            B(40, i) = B(40, i) + 1/16;
        end
    end
end

disp("B");
disp(B);

%Plot B
xData = [10 9 8 7 6 5 4 3 2 1 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 10 10 10 10 10 10 10 10 10];
yData = [0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 10 10 10 10 10 10 10 10 10 10 9 8 7 6 5 4 3 2 1];
figure(1);
G = digraph(transpose(B));
P = plot(G, 'XData', xData, 'YData', yData); %, 'NodeLabel', nodeLabels);
set(gca,'YTick',[])
set(gca,'XTick',[])
set(gca,'XTickLabel',{' '})
set(gca,'YTickLabel',{' '})

%colormap jet;
%P.EdgeCData = G.Edges.Weight;

%Part 2: Initialize w
w = zeros(numberOfSpaces, 1);
%2.1: Start at Go
if(part2 == 1)
    w(1) = 1;    
end

%2.2: Start at every space
if(part2 == 2)
    w = ones(40, 1);
end

%Part 3: Calculate final w vector after convergence
terminalChangeRate = 0.0000001; %If any value in w changed at least this much, iterate another time
currentChangeRate = 1.0;
iteration = 1; %for debugging purposes
while(currentChangeRate > terminalChangeRate)
    wNew = B * w;
    delta = abs(wNew - w);
    currentChangeRate = max(delta);
    w = wNew;
    iteration = iteration + 1;
end

disp("Final w");
disp(w);
disp("Number of iterations to converge")
disp(iteration);

nodeLabels = {}; %{'Go', 'Mediterranean Avenue', 'Community Chest', 'Baltic Avenue', 'Income Tax', 'Reading Railroad', 'Oriental Avenue', 'Chance', 'Vermont Avenue', 'Connecticut Avenue', 'Jail', 'St. Charles Place', 'Electric Company', 'States Avenue', 'Virginia Avenue', 'Pennsylvania Avenue', 'St. James Place', 'Community Chest', 'Tennessee Avenue', 'New York Avenue', 'Free Parking', 'Kentucky Avenue', 'Chance', 'Indiana Avenue', 'Illinois Avenue', 'B. &. O. Railroad', 'Atlantic Avenue', 'Ventnor Avenue', 'Water Works', 'Marvin Gardens', 'Go to Jail', 'Pacific Avenue', 'North Carolina Avenue', 'Community Chest', 'Pennsylvania Avenue', 'Short Line', 'Chance', 'Park Place', 'Luxury Tax', 'Boardwalk'};
xData = [10 9 8 7 6 5 4 3 2 1 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 10 10 10 10 10 10 10 10 10];
yData = [0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 10 10 10 10 10 10 10 10 10 10 9 8 7 6 5 4 3 2 1];
s = zeros(40, 1);
t = zeros(40, 1);
for i=1:40
    nodeLabels{end+1} = num2str(w(i));
    s(i) = i;
    t(i) = mod(i,40) + 1;
end
figure(2);
G2 = graph(s, t);
P2 = plot(G2, 'XData', xData, 'YData', yData, 'NodeLabel', nodeLabels);
colormap jet;
simplifiedW = round(w, 6); %Used to ensure the color scale isn't sensitive to small differences
P2.NodeCData = simplifiedW;
colorbar
set(gca,'YTick',[])
set(gca,'XTick',[])
set(gca,'XTickLabel',{' '})
set(gca,'YTickLabel',{' '})

test = 0;
%Part 4: Determine prioritized order of color properties: 
%Note that the relative value of 1-4 railroads and 1-2 utilities will also
%be considered
%For each 4.1 and 4.2, consider 0 to 4 homes and hotel

%Part 4.0: Create matrix to hold property values (assume monopoly rent)
%Only colored properties for 0 to 4 homes and hotel
propertyValues = [0 0 0 0 0 0; %Go
    4 10 30 90 160 250; %Med
    0 0 0 0 0 0; %Com
    8 20 60 180 320 450; %Bal
    0 0 0 0 0 0; %Inc
    0 0 0 0 0 0; %R
    12 30 90 270 400 550; %Ori
    0 0 0 0 0 0; %Cha
    12 30 90 270 400 550; %Ver
    16 40 100 300 450 600; %Con
    0 0 0 0 0 0; %Jai
    20 50 150 450 625 750; %St.
    0 0 0 0 0 0; %EC
    20 50 150 450 625 750; %Sta
    24 60 180 500 700 900; %Vir
    0 0 0 0 0 0; %P
    28 70 200 550 750 950; %St.
    0 0 0 0 0 0; %Com
    28 70 200 550 750 950; %Ten
    32 80 220 600 800 1000; %New
    0 0 0 0 0 0; %Fre
    36 90 250 700 875 1050; %Ken
    0 0 0 0 0 0; %Cha
    36 90 250 700 875 1050; %Ind
    40 100 300 750 925 1100; %Ill
    0 0 0 0 0 0; %B
    44 110 330 800 975 1150; %Atl
    44 110 330 800 975 1150; %Ven
    0 0 0 0 0 0; %WW
    48 120 360 850 1025 1200; %Mar
    0 0 0 0 0 0; %Go To
    52 130 390 900 1100 1275; %Pac
    52 130 390 900 1100 1275; %Nor
    0 0 0 0 0 0; %Com
    56 150 450 1000 1200 1400; %Pen
    0 0 0 0 0 0; %S
    0 0 0 0 0 0; %Cha
    70 175 500 1100 1300 1500; %Par
    0 0 0 0 0 0; %Lux
    100 200 600 1400 1700 2000]; %Boa

%Finish adding properties and then add railroads and utilities
propertyBaseCost = [0 60 0 60 0 0 100 0 100 120 0 140 0 140 160 0 180 0 180 200 0 220 0 220 240 0 260 260 0 280 0 300 300 0 320 0 0 350 0 400];
propertyHouseCostMultiplier = [0 50 0 50 0 0 50 0 50 50 0 100 0 100 100 0 100 0 100 100 0 150 0 150 150 0 150 150 0 150 0 200 200 0 200 0 0 200 0 200];

colorIndices = [2 4 7 9 10 12 14 15 17 19 20 22 24 25 27 28 30 32 33 35 38 40];
colorStartIndices = [2 7 12 17 22 27 32 38];
propertyIndices = {[2 4] [7 9 10] [12 14 15] [17 19 20] [22 24 25] [27 28 30] [32 33 35] [38 40]};
    
%Railroads (R = Reading Railroad, P = Pennsylvania Railroad, B = B. & O.
%Railroad, S = Short Line)
%R, P, B, S, RP, RB, RS, PB, PS, BS, RPB, RPS, RBS, PBS, RPBS
railroadValues = [25 25 25 25 50 50 50 50 50 50 100 100 100 100 200];
railroadCost = 200; %railroadCost = [200 200 200 200 400 400 400 400 400 400 600 600 600 600 800];
railroadIndices = {[6] [16] [26] [36] [6 16] [6 26] [6 36] [16 26] [16 36] [26 36] [6 16 26] [6 16 36] [6 26 36] [16 26 36] [6 16 26 36]};

%Utilities (EC = Electric Company, W = Water Works
%Assume on average, the player will roll a 7
%EC, WW, ECWW
averageUtilityValues = [28, 28, 70];
utilityCost = 150; %utilityCost = [150 150 300];
utilityIndices = {[13] [29] [13 29]};

%Each row will be the score for either a property, railroad combination, or
%utility combination and each column will be a number of houses
%Thus, this matrix is 58 x 6
scores = zeros(size(propertyValues, 1) + length(railroadValues) + length(averageUtilityValues), 6);

indexKey = {};

%4.1 Consider everything separately
if(part4 == 1)
    for i=1:size(scores, 2)
        for j=1:numberOfSpaces
            if (propertyValues(j, 1) ~= 0)
                scores(j, i) = propertyValues(j, i) * w(j);
            end
        end
    end
    indexKey = {"Mediterranean Avenue", "Baltic Avenue", "Oriental Avenue", "Vermont Avenue", "Connecticut Avenue", "St. Charles Place", "States Avenue", "Virginia Avenue", "St. James Place", "Tennessee Avenue", "New York Avenue", "Kentucky Avenue", "Indiana Avenue", "Illinois Avenue", "Atlantic Avenue", "Ventnor Avenue", "Marvin Gardens", "Pacific Avenue", "North Carolina Avenue", "Pennsylvania Avenue", "Park Place", "Boardwalk", "R", "P", "B", "S", "EC", "WW"};
end

%4.2 Consider colors, raildorads, and utilities together
if(part4 == 2)
    for i=1:size(scores, 2)
        for j=1:length(propertyIndices) %j=1:length(colorStartIndices)
            indices = propertyIndices{j};
            for k=1:length(indices)
                scores(colorStartIndices(j), i) = scores(colorStartIndices(j), i) + propertyValues(indices(k), i) * w(indices(k));
            end
            
        end
    end
    indexKey = {"Dark Purple", "Light Blue", "Pink", "Orange", "Red", "Yellow", "Green", "Dark Blue", "R", "P", "B", "S", "RP", "RB", "RS", "PB", "PS", "BS", "RPB", "RPS", "RBS", "PBS", "RPBS", "EC", "WW", "ECWW"};
end

%Calculate Railroad and Utility scores
railroadEndIndex = length(railroadValues);
utilityEndIndex = length(averageUtilityValues);
if(part4 == 1)
    railroadEndIndex = 4;
end
if(part4 == 1)
    utilityEndIndex = 2;
end
for i=1:size(scores, 2)
    for j=1:railroadEndIndex
        indices = railroadIndices{j};
        for k=1:length(indices)
            scores(numberOfSpaces + j, i) = scores(numberOfSpaces + j, i) + railroadValues(j) * w(indices(k));
        end
    end 
    for j=1:utilityEndIndex
        indices = utilityIndices{j};
        for k=1:length(indices)
            scores(numberOfSpaces + length(railroadValues) + j, i) = scores(numberOfSpaces + length(railroadValues) + j, i) + averageUtilityValues(j) * w(indices(k));
        end
    end
end

%Delete all zero rows
scores(~any(scores,2), :) = [];

%Normalize based on maximum
for i=1:size(scores, 2)
    scores(:,i) = scores(:,i) / max(scores(:,i));
end

disp("Scores");
disp(scores);

disp("Results (Cost of properties not considered)");

%Sort and Display Results
scoreType = {"No Houses", "1 House", "2 Houses", "3 Houses", "4 Houses", "Hotel"};
for i=1:size(scores, 2)
    disp(scoreType{i});
    score = scores(:,i);
    [sortedScore originalIndices] = sort(score, 'descend');
    for j=1:length(sortedScore)
        fprintf("%d. Name: %s, Score: %.6f, Index: %d\n", j, indexKey{originalIndices(j)}, sortedScore(j), originalIndices(j));
    end
    fprintf("\n");
end

%Do the same calculations, but now consider the price of the properties
disp("Now, the cost of properties will be considered)");

scoresWithCost = zeros(size(propertyValues, 1) + length(railroadValues) + length(averageUtilityValues), 6);

indexKey = {};

%4.1 Consider everything separately
if(part4 == 1)
    for i=1:size(scoresWithCost, 2)
        for j=1:numberOfSpaces
            if (propertyValues(j, 1) ~= 0)
                propertyCost = propertyBaseCost(j) + (i - 1) * propertyHouseCostMultiplier(j);
                scoresWithCost(j, i) = propertyValues(j, i) * w(j) / propertyCost;
            end
        end
    end
    indexKey = {"Mediterranean Avenue", "Baltic Avenue", "Oriental Avenue", "Vermont Avenue", "Connecticut Avenue", "St. Charles Place", "States Avenue", "Virginia Avenue", "St. James Place", "Tennessee Avenue", "New York Avenue", "Kentucky Avenue", "Indiana Avenue", "Illinois Avenue", "Atlantic Avenue", "Ventnor Avenue", "Marvin Gardens", "Pacific Avenue", "North Carolina Avenue", "Pennsylvania Avenue", "Park Place", "Boardwalk", "R", "P", "B", "S", "EC", "WW"};
end

%4.2 Consider colors, raildorads, and utilities together
if(part4 == 2)
    for i=1:size(scoresWithCost, 2)
        for j=1:length(propertyIndices) %j=1:length(colorStartIndices)
            indices = propertyIndices{j};
            for k=1:length(indices)
                propertyCost = propertyBaseCost(indices(k)) + (i - 1) * propertyHouseCostMultiplier(indices(k));
                scoresWithCost(colorStartIndices(j), i) = scoresWithCost(colorStartIndices(j), i) + propertyValues(indices(k), i) * w(indices(k)) / propertyCost;
            end
            
        end
    end
    indexKey = {"Dark Purple", "Light Blue", "Pink", "Orange", "Red", "Yellow", "Green", "Dark Blue", "R", "P", "B", "S", "RP", "RB", "RS", "PB", "PS", "BS", "RPB", "RPS", "RBS", "PBS", "RPBS", "EC", "WW", "ECWW"};
end

%Calculate Railroad and Utility scoresWithCost
for i=1:size(scoresWithCost, 2)
    for j=1:railroadEndIndex
        indices = railroadIndices{j};
        for k=1:length(indices)
            scoresWithCost(numberOfSpaces + j, i) = scoresWithCost(numberOfSpaces + j, i) + railroadValues(j) * w(indices(k)) / railroadCost; %railroadCost(indices(k));
        end
    end 
    for j=1:utilityEndIndex
        indices = utilityIndices{j};
        for k=1:length(indices)
            scoresWithCost(numberOfSpaces + length(railroadValues) + j, i) = scoresWithCost(numberOfSpaces + length(railroadValues) + j, i) + averageUtilityValues(j) * w(indices(k)) / utilityCost; %utilityCost(indices(k));
        end
    end
end

%Delete all zero rows
scoresWithCost(~any(scoresWithCost,2), :) = [];

%Normalize based on maximum
for i=1:size(scoresWithCost, 2)
    scoresWithCost(:,i) = scoresWithCost(:,i) / max(scoresWithCost(:,i));
end

disp("Scores with cost");
disp(scoresWithCost);

disp("Results (Cost of properties considered)");

%Sort and Display Results
scoreType = {"No Houses", "1 House", "2 Houses", "3 Houses", "4 Houses", "Hotel"};
for i=1:size(scoresWithCost, 2)
    disp(scoreType{i});
    score = scoresWithCost(:,i);
    [sortedScore originalIndices] = sort(score, 'descend');
    for j=1:length(sortedScore)
        fprintf("%d. Name: %s, Score: %.6f, Index: %d\n", j, indexKey{originalIndices(j)}, sortedScore(j), originalIndices(j));
    end
    fprintf("\n");
end

    