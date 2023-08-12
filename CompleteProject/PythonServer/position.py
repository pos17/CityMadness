import cv2
import numpy as np
import matplotlib.pyplot as plt
from colormath.color_objects import LabColor
from colormath.color_conversions import convert_color

class ImageToMap:
    def __init__(self, image_path, map_reference_points):
        self.image = cv2.imread(image_path)
        self.image_reference_points = []
        self.map_reference_points = map_reference_points

    def find_black_pixels(self):
        black_pixel_count = 0
        for y in range(self.image.shape[0]):
            for x in range(self.image.shape[1]):
                b, g, r = self.image[y, x]
                if r < 10 and g < 10 and b < 10:
                    self.image_reference_points.append((x, y))
                    black_pixel_count += 1
                    #if black_pixel_count >= 2:
                    #    return

    def map_coordinates(self, image_coordinates):
        ref_image_x1, ref_image_y1 = self.image_reference_points[0]
        ref_image_x2, ref_image_y2 = self.image_reference_points[1]
        ref_map_x1, ref_map_y1 = self.map_reference_points[0]
        ref_map_x2, ref_map_y2 = self.map_reference_points[1]
        
        image_width, image_height = self.image.shape[1], self.image.shape[0]

        x_ratio = (ref_map_x2 - ref_map_x1) / (ref_image_x2 - ref_image_x1)
        y_ratio = (ref_map_y2 - ref_map_y1) / (ref_image_y2 - ref_image_y1)

        mapped_x = int((image_coordinates[0] - ref_image_x1) * x_ratio) + ref_map_x1
        mapped_y = int((image_coordinates[1] - ref_image_y1) * y_ratio) + ref_map_y1

        return mapped_x, mapped_y

    def get_rgb_at_map_coordinates(self, map_coordinates):
        mapped_x, mapped_y = map_coordinates
        if 0 <= mapped_x < self.image.shape[1] and 0 <= mapped_y < self.image.shape[0]:
            b, g, r = self.image[mapped_y, mapped_x]
            return r, g, b
        else:
            return (0, 0, 0)  # Default value for points outside the image

    def plot_image_with_reference_points(self):
        plt.imshow(cv2.cvtColor(self.image, cv2.COLOR_BGR2RGB))
        
        for point in self.image_reference_points:
            plt.scatter(point[0], point[1], c='black', marker='o')  # Plot black reference points
        
        plt.title("Image with Reference Points")
        plt.show()

# Example usage
image_path = 'assets/COLORMAPTEST.png'
map_reference_points = [(10, 1), (1, 5)]  # Map reference points

image_to_map = ImageToMap(image_path, map_reference_points)
image_to_map.find_black_pixels()
print(image_to_map.image_reference_points)
# Plot the image with black reference points
image_to_map.plot_image_with_reference_points()

# Query RGB value at a specific map coordinate
map_coordinates_to_query = (4, 2)  # Corresponding map coordinates
rgb_value = image_to_map.get_rgb_at_map_coordinates(map_coordinates_to_query)
print("RGB Value:", rgb_value)