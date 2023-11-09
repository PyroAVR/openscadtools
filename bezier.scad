function qbez(p0, p1, p2, t) = pow(1-t, 2)*p0 + 2*(1-t)*t*p1 + pow(t, 2)*p2;

function proj(vec, normal) = let(v = vec/norm(vec), n = normal/norm(normal)) let(r = v-((v*n)*n)) r/norm(r);

function acosdot(a, b) = acos((a*b)/(norm(a)*norm(b)));

p0 = [20, 10, 0];
p1 = [0, 0, 0];
p2 = [10, 0, 0];

points = [for(i = [0:0.01:1-0.01]) qbez(p0, p1, p2, i)];
pts = concat([p1], points, [p1]);
//polygon([for( e = pts) [e.x, e.y]]);

max_angle = acosdot(p0, p2);
echo(max_angle);

module extrude_between(p0, p1) {
	direction = p1 - p0;
	distance = norm(direction);
	normal = direction / distance;
	// compute a rotation matrix to transform [0, 0, 1] into the new normal
	// no need to re-norm, lengths are already 1
	// ... y ... XZ
	// ... z ... XY
	// rotation in x is the angle between the vectors projected into the YZ plane
	prj_xy = proj(normal, [0, 0, 1]);
	theta_x = 90;
	theta_y = 0;
	temp_angle = acosdot(prj_xy, [1, 0, 0]);
	theta_z = 90-temp_angle;
	//theta_z = temp_angle <= 180-max_angle ? -temp_angle:temp_angle;
	rx = [[1, 0, 0], [0, cos(theta_x), -sin(theta_x)], [0, sin(theta_x), cos(theta_x)]];
	rz = [[cos(theta_z), -sin(theta_z), 0], [sin(theta_z), cos(theta_z), 0], [0, 0, 1]];
	r = (rz*rx);
	// convert translation into an affine so that each segment starts at the current point
	rt = [concat(r[0], p0.x), concat(r[1], p0.y), concat(r[2], p0.z), [0, 0, 0, 1]];
	//translate([0, 0, 1]) multmatrix(rt) rotate([0, -90, 0]) linear_extrude(height=0.1, center=true) text(str(theta_z), size=0.2);
	multmatrix(rt) linear_extrude(height = distance, center=true) children();
}

module curve_extrude(points) {
	for(i = [0:2:len(points)-3]) {
		// calculate the line between points 1 and 2: this is the new normal vector for the children()
		pt0 = points[i];
		pt1 = points[i+1];
		pt2 = points[i+2];
		hull() {
			extrude_between(pt0, pt1) children();
			extrude_between(pt1, pt2) children();
		}
	}
}
curve_extrude(points) {
	circle(r=0.1, $fn=20);
}

