-- Fix default banner URLs that pointed to non-existent uploaded files.
UPDATE ds_banner
SET image_url = CASE
    WHEN image_url = '/uploads/banners/banner1.jpg' THEN '/static/images/home-banner-couture.png'
    WHEN image_url = '/uploads/banners/banner2.jpg' THEN '/static/images/home-banner-leather.png'
    ELSE image_url
END
WHERE image_url IN ('/uploads/banners/banner1.jpg', '/uploads/banners/banner2.jpg');
