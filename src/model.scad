// Whether or not to include support for wrist rest
wrist_rest=true;

// The side-to-side angle of the spacer
roll_angle=15; // [-40:40]

// The back/forth angle of the spacer
pitch_angle=-10; // [-30:0]

// Height of lowest point from the surface
base_height=2; // [0:20]

// Wall thickness
wall_thickness=2; // [0.5:10]

// ------------------------------------
/* [Constants (don't touch these)] */
front_w=107;
front_hole_cc=84;
back_w=113;
base_len=135;
platform_h=200;
corner_radius=15;

wrist_rest_front_w=110;
wrist_rest_back_w=90;
wrist_rest_len=80;

$fn = 100;

module rotate_about_pt(x, y, z, pt) {
	translate(pt)
		rotate([x, y, z])
			translate(-pt)
				children();
}

module shape(front_width, back_width, length, height, corner_rad, shrink_offset=0) {
	minkowski() {
		offs=corner_rad+shrink_offset;
		front_left=[-(front_width/2)+offs, (length/2)-offs];
		front_right=[(front_width/2)-offs, (length/2)-offs];
		back_right=[(back_width/2)-offs, -(length/2)+offs];
		back_left=[-(back_width/2)+offs, -(length/2)+offs];

		back_right_rest=[(wrist_rest_back_w/2)-offs, -(length/2)-(wrist_rest_len/2)+offs];
		back_left_rest=[-(wrist_rest_back_w/2)+offs, -(length/2)-(wrist_rest_len/2)+offs];

		linear_extrude(height, center=true)
			polygon(wrist_rest ? [
				front_left,
				front_right,
				back_right,
				back_right_rest,
				back_left_rest,
				back_left,
			] : [
				front_left,
				front_right,
				back_right,
				back_left,
			]);
		cylinder(height, r=corner_rad, center=true);
	}
}

module hollow_shape() {
	difference() {
		shape(front_w, back_w, base_len, platform_h, corner_radius);
		translate([0, 0, -0.1])
			shape(
				front_w,
				back_w,
				base_len,
				platform_h+10,
				corner_radius,
				wall_thickness
			);
	}
}

module cut_box() {
	cut_box_w=1000;
	cut_box_l=1000;
	cut_box_h=1000;

	translate([0, 0, -500])
		cube([cut_box_w, cut_box_l, cut_box_h], center=true);
}

module on_top_plane() {
	x_origin=roll_angle < 0 ? -front_w/2 : front_w/2;
	y_origin=base_len/2;

	rotate_about_pt(pitch_angle, roll_angle, 0, [x_origin, y_origin])
		translate([0, 0, -platform_h+base_height])
			children();
}

module model() {
	on_top_plane()
		hollow_shape();
}

module solid_model() {
	on_top_plane()
		shape(front_w, back_w, base_len, platform_h, corner_radius);
}

module cut_pins() {
	intersection() {
		translate([0, 0, 50+platform_h])
			cube([1000, 1000, 100], center=true);

		children();
	}
}

module mount_pins() {
	// left
	cut_pins()
		translate([-front_hole_cc/2, base_len/2-corner_radius, 0])
			cylinder(platform_h+4, d=7.5);

	// right
	cut_pins()
		translate([front_hole_cc/2, base_len/2-corner_radius, 0])
			cylinder(platform_h+4, d=7.5);
}

module corner_box(left=true) {
	intersection() {
		solid_model();

		on_top_plane()
			translate([left ? -front_hole_cc/2 : front_hole_cc/2, base_len/2, platform_h+50])
				rotate([40, 0, left ? 45 : -45])
					cube([90, 90, 1000], center=true);
	}
}

difference() {
	union() {
		model();
		on_top_plane()
			mount_pins();
		corner_box(true);
		corner_box(false);
	}
	cut_box();
}
