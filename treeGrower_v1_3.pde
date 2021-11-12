Branch tree;
ArrayList<Branch> list;
boolean stop = false;
boolean save_frame = false;
void setup() {
  size(2000, 1000);
  //fullScreen();
  background(0);
  rectMode(CORNERS);
  fill(255);
  noStroke();

  //init list with first branch
  int init = 0;
  switch (init) {
  case 0:
    tree = new Branch(0, width/2f, height*5/8f, 0);
    list = tree.generate();
    break;
  case 1:
    list = new ArrayList();
    int nx=3;
    int ny=2;
    for (int i = 1; i<nx+1; i++) {
      for (int j=1; j<ny+1; j++) {
        ArrayList<Branch> new_branches = new Branch(0, width*i/(nx+1), height*j/(ny+1), 0).generate();
        for(Branch  b: new_branches)
        list.add(b);
      }
    }
    break;
  default:
    list = new ArrayList();
    list.add(new Branch(0, width/2f, height, 0));
  }
}

void draw() {


  background(0);
  for (Branch b : list) {
    if (!b.update() && save_frame) {
      saveFrame("FRAME.bmp");
      delay(1000);
      exit();
    }
  }
}

//*********************class branch************************************

public class Branch {
  //length and diameter of first branch
  private final float l_0 = 150;
  private final float d_0 = .75;

  //the rate by which l and d get smaller
  private final float l_decay = 0.8f;
  private final float d_decay = .5f;

  //How fast is animation. must be >0
  private final float update_rate = 1;

  //max length: determined by depth n
  private float l_max;
  private float d_max;

  private float d = 0f;
  private float l = 0f; //diameter, length

  private int n; // depth
  private final int n_max = 9;

  private float x, y; //position of branch start
  private float phi = 0; //angle. gets overwritten by parent branch

  //every branch manages its children by itself. Updates are done recursively
  private ArrayList<Branch> children;
  private boolean generated_children = false;

  public Branch(int depth, float x_pos, float y_pos, float parent_angle) {
    n = depth;
    l_max = compute_l();
    d_max = compute_d();
    x = x_pos;
    y = y_pos;

    d = d_max;


    phi = compute_phi(parent_angle);
  }

  //initial branch constructor
  public Branch() {
    //place at bottom, mid-width
    x = width/2f;
    y = height;

    n = 0;

    l_max = l_0;
    d_max = d_0;

    d = d_max;
  }

  //custom angle computations
  private float compute_phi(float parent_angle) {
    return compute_phi(parent_angle, PI/3f, true);
  }
  //start_angle should be positive, otherwise range gets exp. narrower
  private float compute_phi(float parent_angle, float start_angle, boolean naturally) {
    if (naturally) {
      float phi_decay = 1.0001; //the smaller the more likely children will take parent_angle
      float phi_range = start_angle * pow(phi_decay, n);
      float bias = phi_range/2.5f; //select between [0,phi_range/2) and (phi_range/2, phi_range] for c.w. and c.c.w. rotation respectively
      return parent_angle + random(-bias, phi_range - bias);
    } else {
      float f = random(0, 1);
      //choose >2 for good results
      float split = 3;
      float cut = 2*PI / split;
      int i;
      for (i=0; i< f * 2*PI; i++);
      return i*cut;
    }
  }
  private float compute_l() {
    return l_0 * pow(l_decay, n);
  }
  private float compute_d() {
    return d_0 * pow(d_decay, n);
  }

  public boolean update() { //TODO is boolean still necessary?
    //returns true for length update and false if final length reached.
    //but returns true again if children are generated, st. no more children are gen.
    boolean size = l<l_max;
    boolean set = false;
    boolean return_val = true;
    if (size) {//the branch is still growing
      l += update_rate;// + random(0,l_0*pow(.5,n));
      //d = (l/l_max) * d_max;
    } else {//branch is fully grown -> check for children
      if (generated_children) {
        if (children!=null) {
          return_val = false; //assume all children terminated
          for (int i=0; i<children.size(); i++) {
            boolean update = children.get(i).update();
            if (update && !set) {
              set = true;
              return_val = true;
            }
            //return_val = return_val || children.get(i).update();
          }
        } else {
          return_val =  false;
        }
      } else {//generate children
        children = generate();
      }
    }
    draw_branch();
    return return_val;
  }

  private void draw_branch() { 
    pushMatrix();
    translate(x, y);
    rotate(phi); 
    //draw from botton up, so in -y (if phi==0)
    rect(-d/2f, 0, d/2f, -l);
    popMatrix();
  }

  //generate children
  public ArrayList<Branch> generate() { 
    generated_children = true;

    //return a null list if max depth is reached -> this is checked for in fct. 'update'
    if (n<n_max) {
      ArrayList<Branch> new_branches= new ArrayList();
      //#children
      int m = int(random(0, 8));
      for (int i=0; i<m; i++) {
        new_branches.add(new Branch(n+1, x+l*sin(phi), y-l*cos(phi), phi));
      }
      return new_branches;
    } else {
      return null;
    }
  }
}
