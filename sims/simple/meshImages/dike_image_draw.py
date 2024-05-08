from PIL import Image, ImageDraw
import numpy as np

def dike_image_draw(angle, intercept, thickness):
  # Create a new image with white background
  image = Image.new("RGB", (2000, 2000), "white")
  draw = ImageDraw.Draw(image)
  intercept = 2000 - intercept

  # Calculate the coordinates of the line
  x1 = 0
  y1 = int(intercept)
  x2 = 2000
  y2 = int(-1*np.tan(np.deg2rad(angle)) * x2 + intercept)

  # Draw the line on the image
  draw.line([(x1, y1), (x2, y2)], fill="black", width=thickness)

  # Save the image
  filename = f"dike_pic_{angle}_{intercept}_{thickness}.jpg"
  image.save(filename)
  return image

#loop across angles and intercepts
for angle in range(20, 60, 10):
    image = dike_image_draw(angle, 400, 10)


