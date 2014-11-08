$do_prerender=true;

include <config.scad>
include <GDMUtils.scad>
use <NEMA.scad>

use <build_platform_support_parts.scad>
use <cantilever_joint_parts.scad>
use <cantilever_arm_parts.scad>
use <drive_gear_parts.scad>
use <extruder_platform_parts.scad>
use <motor_mount_plate_parts.scad>
use <rail_endcap_parts.scad>
use <rail_motor_segment_parts.scad>
use <rail_segment_parts.scad>
use <sled_endcap_parts.scad>
use <sled_parts.scad>
use <support_leg_parts.scad>
use <xy_joiner_parts.scad>
use <yz_joiner_parts.scad>


// Set default camera position.
$vpd = 700;
$vpt = [0, 0, 255];
$vpr = [65, 0, 120];


platform_vert_off = rail_height+groove_height+rail_offset;


module axis_slider_assembly(slidepos=0)
{
	translate([0, -motor_rail_length/2, 0]) {
		translate([0, -rail_length/2, 0]) {
			rail_segment();
		}
	}
	rail_motor_segment();
	translate([0, motor_rail_length/2, 0]) {
		translate([0, rail_length/2, 0]) {
			rail_segment();
		}
	}

	// Stepper Motor
	translate([0, 0, 30]) {
		motor_mount_plate();
		translate([0, 0, 5.9+rail_thick]) {
			nema17_stepper(h=34, shaft_len=20.05);
			translate([0, 0, 17]) {
				drive_gear();
			}
		}
	}

	// Sleds
	translate([0, slidepos, platform_vert_off]) {
		grid_of(count=[1,2], spacing=platform_length) {
			yrot(180) {
				sled();
			}
		}
		children();
	}
}


module full_assembly(hide_endcaps=false)
{
	joiner_length=15;
	xpos = 90*cos(360*$t);
	ypos = 90*sin(360*$t);
	zpos = 90*cos(240+360*$t);

	// Y-axis to Z-axis corner joiner.
	yz_joiner();

	// Support legs.
	translate([0, platform_length/2, 0]) {
		zrot_copies([0,180]) {
			translate([rail_width/2+2*7, 0, 0]) {
				zrot(-90) support_leg();
			}
		}
	}

	translate([0, platform_length + rail_length + motor_rail_length/2, 0]) {
		// Y-axis rail endcaps.
		if (hide_endcaps == false) {
			translate([0, motor_rail_length/2 + rail_length, 0]) {
				zrot(180) rail_endcap();
			}
		}

		// Y-axis rails.
		axis_slider_assembly(ypos) {
			// X-axis to Y-axis joiners.
			zrot_copies([0, 180]) {
				translate([0, -platform_length, 0]) {
					xy_joiner();
				}
			}
			zrot(90) {
				// X-axis rail endcaps.
				if (hide_endcaps == false) {
					zrot_copies([0, 180]) {
						translate([0, -(rail_length + motor_rail_length/2), 0]) {
							rail_endcap();
						}
					}
				}

				// X-axis rails.
				axis_slider_assembly(xpos) {
					zrot_copies([0, 180]) {
						translate([0, -platform_length, 0]) {
							sled_endcap();
							translate([0, -(20-joiner_width/2), 0]) {
								translate([platform_width/2, 0, 0]) {
									zrot(90) build_platform_support2();
								}
								translate([-platform_width/2, 0, 0]) {
									zrot(270) build_platform_support1();
								}
							}
						}
					}
					translate([0, 0, 3+glass_thick/2]) {
						// Borosilicate Glass
						color([0.75, 1.0, 1.0, 0.5]) {
							cube(size=[glass_width, glass_length, glass_thick], center=true);
						}
					}
				}
			}
		}
	}

	translate([0, 0, platform_length + rail_length + motor_rail_length/2]) {
		xrot(-90) {
			// Z-axis rail endcaps.
			if (hide_endcaps == false) {
				translate([0, -(motor_rail_length/2 + rail_length+0.1), 0]) {
					rail_endcap();
				}
			}
			// Z-axis rails.
			axis_slider_assembly(zpos) {
				translate([0, -platform_length, 0]) {
					xrot(90) {
						// Z-axis platform to extruder cantilever joint.
						cantilever_joint();

						// Extruder cantilever.
						translate([0, joiner_length, -(platform_length+rail_height)/2]) {
							translate([0, cantilever_length/2, 0]) {
								cantilever_arm();
								translate([0, cantilever_length/2, 0]) {
									extruder_platform();
								}
							}
						}
					}
				}
			}
		}
	}
}


translate([0,-1.5*rail_length,0])
	full_assembly(hide_endcaps=false);



// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap

