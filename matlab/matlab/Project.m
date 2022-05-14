clc
clear all
close all
%% Loading Images into MATLAB
desiredFile1='Parking Lot with Cars'; % Name of image with cars in the parking
desiredFile2='Parking Lot without Cars'; % Name of image without cars in the parking
desiredFile3='Parking Lot Mask'; % Name of image of parking mask
message='Do you want to start analysis in current folder?'; % showing message 
if isequal(questdlg(message,'Message','Yes','Change Folder','Yes'),'Change Folder') % choosing option
    cd(uigetdir(pwd)); % changing folder
end
fnd1=false; fnd2=false; fnd3=false; % to check if all three files have been found
while(true) % loop until images or found or user cancels the operation
    images=dir(pwd); %searching in currnt folder
    for i=1:length(images) % for loop to go throgh all images in folder
        [~,name,~]=fileparts(images(i).name); % reads name of the images in folder 
        if isequal(name,desiredFile1) % checks if image name matches our desired name
            filledParking=imread(images(i).name); % reads image into workspace
            fnd1=true; % sets find1 as truebw
        end
        if isequal(name,desiredFile2)  % checks if image name matches our desired name
            emptyParking=imread(images(i).name);% reads image into workspace
            fnd2=true;  % sets find2 as true
        end
        if isequal(name,desiredFile3) % checks if image name matches our desired name
            parkingMask=imread(images(i).name); % reads image into workspace
            fnd3=true;  % sets find3 as true
        end
        if fnd1&&fnd2&&fnd3 % checks if all three find are true
            break; % stops searching
        end
    end
    if ~(fnd1&&fnd2&&fnd3) % if find is false 
        errorMessage = sprintf('Error: one of desired images does not exist,Pls Select correct folder.'); % error message
        ch=questdlg(errorMessage,'Message','Select Folder','Cancel','Cancel'); % gives error message plus optons to chose
        if isequal(ch,'Select Folder') % if chosen option is select folder
            cd(uigetdir);  %then new folder is selected 
        else
            return; % stops code if user chose cancel
        end
    else
        break; % if all three find true then stops image search
    end
end
%% Pre-Processing of Images
fig1=figure(); % creates figure
fig1.WindowState = 'maximized'; % maximizes the window
subplot(2,3,1) % subplot at 1st location in 2x3 grid
imshow(filledParking); % show filled parking image
axis off; % switch off axis, as we are displaying images
title('Parking filled with cars'); % title of the 1st subplot
subplot(2,3,2) % 2nd subplot
imshow(emptyParking); % show empty parking image
axis off; % switch off axis, as we are displaying images
title('Empty Parking'); % title of the 2nd subplot
subplot(2,3,3) % 3rd subplot
bwMask=max(parkingMask,[],3)==255; %  masks images at maximum intesnity of 255
props=regionprops(bwMask,'BoundingBox','Area','Centroid'); % detects object's BoundingBox,Area and Centroid
imshow(bwMask); % display binary mask 
m=1; % varaible to count and store detected objects
for i=1:length(props) % loop through all detected objects
    if(props(i).Area>1000) % check if area of detected object is higher than 1000, to remove 
        rectangle('Position',props(i).BoundingBox,'EdgeColor','r','LineWidth',2 ); % plots red boxes around detected objects
        allLocations{m}=props(i).BoundingBox; % saves locations of bounding boxes of all detected objects
        allCentroids{m}=props(i).Centroid; % saves centroid locations of all detected objects
        m=m+1; % increment
    end
end
axis off; % switch off axis
title('Parking Mask'); % subplot title
subplot(2,3,4) % 4th subplot
diffImage=imabsdiff(filledParking,emptyParking); % difference image of filled and empty parking
imshow(diffImage); % displays iamage
axis off; % switch off axis
title('Difference Image'); % title of image
subplot(2,3,5) % 5th subplot
diffImage=rgb2gray(diffImage); % grayscale conversion
diffImage(~bwMask)=0; % set all pixels except masked pixels to zero
imshow(diffImage); % show image
axis off; % axis off
title('Gray Scale Difference Image'); % title of image
grayI= diffImage; 
threshold=graythresh(diffImage)*100;  % threshold value of image,
parkedCars=diffImage>threshold; % apply threshold
parkedCars=imfill(parkedCars, 'holes'); % fill the holes
parkedCars=imerode(parkedCars,strel('rectangle',[5,10])); % erode the image
parkedCars=bwconvhull(parkedCars, 'objects'); % calculate convex hull of image objects
subplot(2,3,6); % 6th subplot
imshow(parkedCars); % show image
axis off; % axis off
title(sprintf('Parked Cars Binary Image with Threshold = %.1f', threshold)); % title of image
iprops=regionprops(bwMask,parkedCars,'BoundingBox','MeanIntensity'); % detect Bounding Boz and mean Intensity of parked cars
m=1; % varaible to count and store detected objects
for i=1:length(iprops)
    if(iprops(i).MeanIntensity>0.1) % check if mean intensity of detected object is more than 0.1
        rectangle('Position',iprops(i).BoundingBox,'EdgeColor','y','LineWidth',2 ); % plot yellow box around the detected car
        takenLocations{m}=iprops(i).BoundingBox; % save bounding box info
        m=m+1; % increment 
    end
end
fig1.Name = 'Car Parking Analysis'; % NAme 1st figure
fig2=figure(); % creates 2nd figure
imshow(filledParking) % display filled parking image
fig2.WindowState = 'maximized'; % maximizes the window
for i=1:length(allLocations) % loop through all detected parking spots
    taken=false; % set taken as false
    box1=allLocations{i}; % location of parking spot
    r1=rectangle('Position',box1,'EdgeColor','r','LineWidth',2 ); % plot box around the location
    for j=1:length(takenLocations) % loop through taken locations, where car is parked 
        box2=takenLocations{j}; % parked car location
        r2=rectangle('Position',box2,'EdgeColor','y','LineWidth',2 ); % plot box around the location
        ratio=bboxOverlapRatio(box1,box2); % check if parking spot box and parked car box overlaps
        if ratio>0.1 % if overlapping ratio is more than 0.1
            cent=allCentroids{i}; % get centroid of the location
            hold on
            plot(cent(1),cent(2),'-x','Color','r','markerSize',25,'lineWidth',8); % plot x in red to mark spot as taken
            hold off
            taken=true; % set taken as true
            break; % exit the loop
        end
    end
    if ~taken % if not taken
        cent=allCentroids{i}; % get centroid of location
        hold on
        plot(cent(1),cent(2),'-o','Color','g','markerSize',25,'lineWidth',8); % plots green O to mark spot as available
        hold off
    end
end
rect=findall(gcf,'Type','Rectangle'); % detects all boxes used to detect/mark parking spots
delete(rect); % deletes all boxes used during analysis, they don't need to be displayed 
fig2.Name = 'Results'; % name the figure
title('Marked Spaces.  Green O = Available.  Red X = Taken.'); % title of figure


