function star_pixels = star_BG_classifier(pixels)
    max_star_R = 5;
    BG_pixels = pixels((pixels(:,1)>max_star_R),:);
    for ii = 1:5
        avg = mean(BG_pixels(:,2));
        sigma = std(BG_pixels(:,2));
        BG_pixels(BG_pixels(:,2)>avg+sigma*2,:) = [];
    end
    star_pixels = pixels((pixels(:,1)<max_star_R),:);
    BG_level = mean(BG_pixels(:,2));
    star_pixels(:,2) = star_pixels(:,2) - BG_level;
end