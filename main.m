close all;
clear;
g = @(A,X) A(1)*exp(-(X-A(2)).^2/(2*A(3)^2));
%%
origin=imread('my_image.jpg');
% figure; imshow(origin);
gray = rgb2gray(origin);
[H,W] = size(gray);
figure(1); imshow(gray);
%% unsharpen
unsharpen = imbinarize(gray - imgaussfilt(gray,30),0.3);
% figure; imshow(unsharpen);
%% connect pixels
CC = bwconncomp(unsharpen,4);
star_list.pixels = CC.PixelIdxList';
ii = 1;
while ii <= length(star_list.pixels)
    if (length(star_list.pixels{ii})<=4)...
            || any(gray(star_list.pixels{ii})>250)
        star_list.pixels(ii) = [];
    else
        ii = ii+1;
    end
end

%% plot star list pixels
% I = gray*0;
% for ii = 1:length(star_list.pixels)
%     I(star_list.pixels{ii}) = 255;
% end
% figure; imshow(I);
%% center
I2 = gray*0;
star_list.pixel_xy = cell(length(star_list.pixels),1);
star_list.center = zeros(length(star_list.pixels),2);
for ii = 1:length(star_list.pixels)
    star_list.pixel_xy(ii) = {[floor((star_list.pixels{ii}-1)/H)+1 mod(star_list.pixels{ii}-1,H)+1]};
    x = star_list.pixel_xy{ii}(:,1);
    y = star_list.pixel_xy{ii}(:,2);
    total_flux = 0; center_x = 0; center_y = 0;
    for jj = 1:length(x)
        total_flux = total_flux + double(gray(y(jj),x(jj)));
        center_x = center_x + x(jj)*double(gray(y(jj),x(jj)));
        center_y = center_y + y(jj)*double(gray(y(jj),x(jj)));
    end
    center_x = center_x/total_flux;
    center_y = center_y/total_flux;
    star_list.center(ii,:) = [center_x, center_y];
end 
figure(1);  hold on; plot(star_list.center(:,1), star_list.center(:,2),'*r');
% figure; imshow(I2);
%% FWHM
figure;
search_R = 10;
max_star_R = 5;
star_list.FWHM = zeros(length(star_list.center),3);
for ii = 1:length(star_list.center)
    if star_list.center(ii,1)>=search_R+1 && (W-star_list.center(ii,1))>=search_R+1 &&...
         star_list.center(ii,2)>=search_R+1 && (H-star_list.center(ii,2))>=search_R+1
        x = ceil(star_list.center(ii,1)-search_R):ceil(star_list.center(ii,1)+search_R);
        y = ceil(star_list.center(ii,2)-search_R):ceil(star_list.center(ii,2)+search_R);
        [X,Y] = meshgrid(x,y);
        tmp = double(gray(y,x));
        sample_point = [vecnorm([star_list.center(ii,1)-X(:) star_list.center(ii,2)-Y(:)],2,2), tmp(:)]; 
        star_pixels = star_BG_classifier(sample_point);
        x = [star_pixels(:,1); -star_pixels(:,1)];
        y = [star_pixels(:,2); star_pixels(:,2)];
        [a,sigma,error] = Gfit(x,y);
        if isreal(sigma) && error<15
            FWHM = 2.35482 * sigma;
            clf; plot(star_pixels(:,1),star_pixels(:,2),'*');
            h=4; xfit=0:1/h:6; A=[a,0,sigma]; hold on; plot(xfit,g(A,xfit),'-r'); grid on;
            xline(FWHM/2,'r'); xline(2.35482 * sigma/2,'b');
            star_list.FWHM(ii,:) = [star_list.center(ii,1) star_list.center(ii,2) FWHM];
        end
    end
end
star_list.FWHM(star_list.FWHM(:,3)==0,:) = [];
%% draw
plot3(star_list.FWHM(:,1),star_list.FWHM(:,2),star_list.FWHM(:,3),'*');
sf = fit([star_list.FWHM(:,1), star_list.FWHM(:,2)],star_list.FWHM(:,3),'poly55');
plot(sf,[star_list.FWHM(:,1), star_list.FWHM(:,2)],star_list.FWHM(:,3));
