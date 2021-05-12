// Params
with_wrist_rest=true;
roll_angle=-15;
pitch_angle=15;
base_height=0;
wall_thickness=2;

// Constants (may mess up model)
front_w=107;
front_hole_cc=84;
back_w=113;
platform_l=135;
platform_h=200;
corner_radius=15;

$fn = 100;

module rotate_about_pt(x, y, z, pt) {
	translate(pt)
		rotate([x, y, z])
			translate(-pt)
				children();
}

module rounded_four_square(front_width, back_width, length, height, corner_rad) {
	minkowski() {
		linear_extrude(height, center=true)
			polygon([
					// front left
					[-(front_width/2)+corner_rad, (length/2)-corner_rad],
					// front right
					[(front_width/2)-corner_rad, (length/2)-corner_rad],
					// back right
					[(back_width/2)-corner_rad, -(length/2)+corner_rad],
					// back left
					[-(back_width/2)+corner_rad, -(length/2)+corner_rad],
			]);
		cylinder(height, r=corner_rad, center=true);
	}
}

module hollow_shape() {
	difference() {
		rounded_four_square(front_w, back_w, platform_l, platform_h, corner_radius);
		translate([0, 0, -0.1])
			rounded_four_square(
				front_w-(wall_thickness*2),
				back_w-(wall_thickness*2),
				platform_l-(wall_thickness*2),
				platform_h+10,
				corner_radius-wall_thickness
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
	rotate_about_pt(roll_angle, pitch_angle, 0, [front_w/2, platform_l/2])
		translate([0, 0, -platform_h+base_height])
			children();
}

module solid_model() {
	on_top_plane()
		rounded_four_square(front_w, back_w, platform_l, platform_h, corner_radius);
}

module model() {
	on_top_plane()
		hollow_shape();
}

module cut_pins() {
	intersection() {
		translate([0, 0, 50+platform_h])
			cube([1000, 1000, 100], center=true);

		children();
	}
}

module mount_pins() {
	cut_pins() {
		// left
		translate([-front_hole_cc/2, platform_l/2-corner_radius, 0]) {
			cylinder(platform_h+4, d=7.5);
		}
	}

	cut_pins() {
		// right
		translate([front_hole_cc/2, platform_l/2-corner_radius, 0])
			cylinder(platform_h+4, d=7.5);
	}
}

module corner_box(left=true) {
	intersection() {
		solid_model();

		on_top_plane()
			translate([left ? -front_hole_cc/2 : front_hole_cc/2, platform_l/2, platform_h+50])
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
