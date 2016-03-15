
class BezierCurve {

  PVector v0, v1, v2, v3;
  float t;
  float speed;
  float d_factor = 1;
  IntList dependent_pixels;
  boolean finished = false;
  boolean disappearing = false;
  color c=0;
  float size;

  BezierCurve(PVector a, PVector b, PVector c, PVector d, int num_pixels, int num_curves) {
    v0 = a; // curve begins here
    v1 = b;
    v2 = c;
    v3 = d; // curve ends here
    t  = 0;
    speed = 0.02 + random(0.01);
    speed /= 3.5;
    dependent_pixels = new IntList();
    float avg_num_pixels_per_curve = (float)num_pixels / num_curves;
    size = 2 + sqrt(avg_num_pixels_per_curve/PI);
  }

  PVector getPoint() {
    PVector result = new PVector();
    result.x = bezierPoint(v0.x, v1.x, v2.x, v3.x, t);
    result.y = bezierPoint(v0.y, v1.y, v2.y, v3.y, t);
    return result;
  }

  PVector pointAtParameter(float t) {
    PVector result = new PVector();
    result.x = bezierPoint(v0.x, v1.x, v2.x, v3.x, t);
    result.y = bezierPoint(v0.y, v1.y, v2.y, v3.y, t);
    return result;
  }

  void setColor(color c) {
    this.c = c;
  }

  void increaseT() {

    if (t >= 1 && !finished) {
      t=1;
      finish();
    } else if (!finished) t += speed * (1+random(1));
  }

  void draw() {
    if (!finished) {
      stroke(c);
      PVector currentPoint = getPoint();
      strokeWeight( size + 2*size*(1-t)*(1-t) );
      point(currentPoint.x, currentPoint.y);
    } else if (disappearing) {
      finish();
      d_factor += 0.1;
      stroke(c);
      strokeWeight( size / d_factor );
      point(v3.x, v3.y);
      if(d_factor > size) disappearing = false;
    }
  }

  void addDependent(int idx) {
    dependent_pixels.append(idx);
  }

  void finish() {
    result.loadPixels();
    for (int i=0; i<dependent_pixels.size(); i++) {
      int idx = dependent_pixels.get(i);
      float red = red(result.pixels[idx]);
      float blue = blue(result.pixels[idx]);
      float green = green(result.pixels[idx]);
      color c = color(red, green, blue, 255);
      result.pixels[idx] = c;
    }
    finished=true;
    disappearing=true;
    result.updatePixels();
  }
};