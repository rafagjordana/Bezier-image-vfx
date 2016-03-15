BezierCurve[] curve;
PImage test, filtered, result;
int dimx, dimy;
IntList pixel_index;
IntList pixel_partner;
final int number_of_points = 1000;

void setup() {
  size(960, 540);
  background(255);
  frameRate(30);

  test = loadImage("test images/test4.jpg");
  filtered = loadImage("test images/test4.jpg");
  dimx = test.width;
  dimy = test.height;
  result = createImage(dimx, dimy, ARGB);

  pixel_index = new IntList();
  pixel_partner = new IntList();
  curve = new BezierCurve[number_of_points];

  filtered.filter(INVERT);
  filtered.filter(THRESHOLD, 0.05);
  test.loadPixels();
  filtered.loadPixels();
  result.loadPixels();

  for (int i=0; i<dimx*dimy; i++) {
    float red = red(test.pixels[i]);
    float blue = blue(test.pixels[i]);
    float green = green(test.pixels[i]);
    color c = color(red, green, blue, 0);
    result.pixels[i] = c;
  }

  result.updatePixels();

  for (int i=0; i<dimx*dimy; i++) {
    if (brightness(filtered.pixels[i]) >= 255 ) {
      pixel_index.append(i);
    }
  }

  int remaining_curves = number_of_points;

  for (int i = 0; i<pixel_index.size(); i++) {
    float chance = 1 - (float)remaining_curves / (float)(pixel_index.size()-i);
    if ( random(1) > chance ) {
      PVector a = new PVector(random(900), -300);
      PVector b = new PVector(2*random(width)-width/2, 2*random(height)-height/2);
      PVector c = new PVector(2*random(width)-width/2, 2*random(height)-height/2);
      PVector d = new PVector(pixel_index.get(i) % dimx, pixel_index.get(i) / dimx);
      curve[number_of_points-remaining_curves] = new BezierCurve(a, b, c, d, pixel_index.size(),number_of_points);
      remaining_curves--;
    }
  }
  
  for(int i = 0; i<number_of_points; i++){
    curve[i].setColor(test.pixels[(int)(curve[i].v3.y*dimx+curve[i].v3.x)]);
  }
  
  for (int i = 0; i<pixel_index.size(); i++) {
    float min_dist = 1000;
    float ac_dist;
    int min_idx = 0;
    for (int j = 0; j<number_of_points; j++) {
      ac_dist = imageDistance(pixel_index.get(i), (int)curve[j].v3.x, (int)curve[j].v3.y);
      if (ac_dist < min_dist) {
        min_dist = ac_dist;
        min_idx = j;
      }
    }
    pixel_partner.append(min_idx);
    curve[min_idx].addDependent(pixel_index.get(i));
  }
}


void draw() {
  translate(200,200);
  background(255);
  for (int i=0; i<number_of_points; i++) {
    curve[i].increaseT();
    curve[i].draw();
  }

  image(result, 0, 0);
}


float imageDistance(int id1, int x2, int y2) {

  int x1 = id1 % dimx;
  int y1 = id1 / dimx;
  int difx = x2-x1;
  int dify = y2-y1;

  float dist = sqrt(difx*difx+dify*dify);
  return dist;
}