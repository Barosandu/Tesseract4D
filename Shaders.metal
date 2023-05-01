//
//  Shaders.metal
//  ObjectsIn4DAritonAlexandru
//
//  Created by Alexandru Ariton on 07.04.2022.
//

#include <metal_stdlib>
#define PI 3.14
#define EPSILON 0.001
#define IDENTITY_ROTATION_MATRIX float4x4(1, 0, 0, 0 , 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
#define IDENTITY_TRANSFORMATION float4(0, 0, 0, 0)
#define IDENTITY_TRANSFORMATION_CENTER float4(0, 0, -3, 0)
#define ZERO_SIZE float4(0, 0, 0, 0)
#define CUBE 0
#define BOX 1
#define SPHERE 2
#define SMOOTH_BOX 3
#define TORUS 4
#define SMOOTH_CUBE 5
#define CUBE_THAT_TURNS_INTO_SPHERE 6
#define CUBE_THAT_TURNS_INTO_TORUS 7

#define MAX_DEPTH 5

using namespace metal;


float highPerformanceSIN(float theta) {
    return sin(theta);
    //    if(abs(theta) <= PI) {
    //        return theta - theta * theta * theta / 6.0 + theta * theta * theta * theta * theta / 120.0 + theta * theta * theta * theta * theta * theta * theta / 5040.0;
    //    } else if(abs(theta) > PI && abs(theta) <=  2 * PI) {
    //        return -highPerformanceSIN(abs(theta) / theta * (abs(theta) - PI));
    //    } else if(abs(theta) > 2 * PI) {
    //        return highPerformanceSIN(abs(theta) / theta * fmod(abs(theta), 2 * PI));
    //    }
}

float highPerformanceCOS(float theta) {
    return cos(theta);
}

float sdf_blend(float d1, float d2, float a) {
    return a * d1 + (1 - a) * d2;
}

float4 sdf_blend4(float4 d1, float4 d2, float a) {
    return a * d1 + (1 - a) * d2;
}





struct PrimitiveObject4d {
    float4 semisize;
    float4 transformation4d;
    float4x4 rotation_matrix;
    int primitive_type = 0;
    float coefficient_for_changing_shape = 0;
    
    PrimitiveObject4d(float4 _semisize, float4 _transformation4d, float4x4 _rotation_matrix, int _primitive_type) {
        semisize = _semisize;
        transformation4d = _transformation4d;
        rotation_matrix = _rotation_matrix;
        primitive_type = _primitive_type;
    }
    PrimitiveObject4d() {
        semisize = ZERO_SIZE;
        transformation4d = IDENTITY_TRANSFORMATION;
        rotation_matrix = IDENTITY_ROTATION_MATRIX;
        primitive_type = 0;
    }
    
    float4 transformPoint(float3 point, float camera_w) {
        float4 transformation = this->transformation4d;
        float4x4 rotation = this->rotation_matrix;
        float4 semisize = this->semisize;
        float4 p4d = float4(point, camera_w);
        float4 p = (p4d + transformation) * rotation;
        return p;
    }
    
    float sdf_4d_torus(float4 p) {
        float r1 = semisize.x;
        float r2 = semisize.y;
        float r3 = semisize.z;
        float x = length(p.xz) - r1;
        float y = length(float2(x, p.y)) - r2;
        float d = length(float2(y, p.w)) - r3;
        return d;
    }
    
    float sdf_4d_box(float4 p) {
        float4 r = semisize;
        float4 q = abs(p) - r;
        float d = length(max(q, 0)) + min(max(q.x, max(q.y, max(q.z, q.w))), 0.0);
        return d;
    }
    
    float sdf_4d_smooth_box(float4 p) {
        return sdf_4d_box(p) - 0.1;
    }
    
    float sdf_4d_sphere(float4 p) {
        float4 center = this->transformation4d;
        return distance(center, float4(p)) - this->semisize[0] ;
    }
    
    
    
    
    // MARK: SDF
    float signed_distance_function(float3 point, float camera_w, float power = 0) {
        float4 pct = transformPoint(point, camera_w);
        if (primitive_type == CUBE || primitive_type == BOX) {
            return sdf_4d_box(pct);
        } else if(primitive_type == TORUS) {
            return sdf_4d_torus(pct);
        } else if(primitive_type == SPHERE) {
            return sdf_4d_sphere(pct);
        } else if(primitive_type == SMOOTH_BOX || primitive_type == SMOOTH_CUBE) {
            return sdf_4d_smooth_box(pct);
        } else if(primitive_type == CUBE_THAT_TURNS_INTO_SPHERE) {
            float d_cube = sdf_4d_box(pct);
            float d_sphere = sdf_4d_sphere(pct);
            return sdf_blend(d_cube, d_sphere, coefficient_for_changing_shape);
        } else if(primitive_type == CUBE_THAT_TURNS_INTO_TORUS) {
            float d_cube = sdf_4d_box(pct);
            float d_torus = sdf_4d_torus(pct);
            return sdf_blend(d_cube, d_torus, coefficient_for_changing_shape);
        }
    }
    float signed_distance_function_primitive(int prim, float3 point, float camera_w) {
        float4 pct = transformPoint(point, camera_w);
        if (prim == CUBE || primitive_type == BOX) {
            return sdf_4d_box(pct);
        } else if(prim == TORUS) {
            return sdf_4d_torus(pct);
        } else if(prim == SPHERE) {
            return sdf_4d_sphere(pct);
        } else if(prim == SMOOTH_BOX || prim == SMOOTH_CUBE) {
            return sdf_4d_smooth_box(pct);
        } else if(prim == CUBE_THAT_TURNS_INTO_SPHERE) {
            float d_cube = sdf_4d_box(pct);
            float d_sphere = sdf_4d_sphere(pct);
            return sdf_blend(d_cube, d_sphere, coefficient_for_changing_shape);
        } else if(prim == CUBE_THAT_TURNS_INTO_TORUS) {
            float d_cube = sdf_4d_box(pct);
            float d_torus = sdf_4d_torus(pct);
            return sdf_blend(d_cube, d_torus, coefficient_for_changing_shape);
        }
    }
    
};








struct Ray {
    float3 origin;
    float3 direction;
    Ray(float3 o, float3 d) {
        origin = o;
        direction = d;
    }
};

struct Sphere {
    float3 center;
    float radius;
    Sphere(float3 c, float r) {
        center = c;
        radius = r;
    }
};

struct Box4d {
    float4 semisize;
    Box4d(float4 s) {
        semisize = s;
    }
};

float3x3 rotation_matrix_z(float angle_deg) {
    float k = angle_deg * PI / 180;
    float3x3 mak = float3x3(highPerformanceCOS(k), -highPerformanceSIN(k), 0,
                            highPerformanceSIN(k), highPerformanceCOS(k), 0,
                            0, 0, 1);
    return mak;
}

float3x3 rotation_matrix_y(float angle_deg) {
    float w = angle_deg * PI / 180;
    
    float3x3 mak = float3x3(highPerformanceCOS(w), 0, highPerformanceSIN(w),
                            0, 1, 0,
                            -highPerformanceSIN(w), 0, highPerformanceCOS(w));
    return mak;
}

float3x3 rotation_matrix_x(float angle_deg) {
    float g = angle_deg * PI / 180;
    float3x3 mak = float3x3(1, 0, 0,
                            0, highPerformanceCOS(g), -highPerformanceSIN(g),
                            0, highPerformanceSIN(g), highPerformanceCOS(g));
    return mak;
}

float3x3 rotation_matrix_xyz(float3 xyz_deg) {
    float3x3 mx = rotation_matrix_x(xyz_deg.x);
    float3x3 my = rotation_matrix_y(xyz_deg.y);
    float3x3 mz = rotation_matrix_z(xyz_deg.z);
    float3x3 m = (mx * my) * mz;
    return m;
}

float4x4 rotation_matrix_yz(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(1, 0, 0, 0,
                            0, highPerformanceCOS(t), -highPerformanceSIN(t), 0,
                            0, highPerformanceSIN(t), highPerformanceCOS(t), 0,
                            0, 0, 0, 1);
    return mak;
}

float4x4 rotation_matrix_xy(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(highPerformanceCOS(t), -highPerformanceSIN(t), 0, 0,
                            highPerformanceSIN(t), highPerformanceCOS(t), 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1);
    return mak;
}

float4x4 rotation_matrix_yw(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(1, 0, 0, 0,
                            0, highPerformanceCOS(t), 0, -highPerformanceSIN(t),
                            0, 0, 1, 0,
                            0, highPerformanceSIN(t), 0, highPerformanceCOS(t));
    return mak;
}

float4x4 rotation_matrix_zx(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(highPerformanceCOS(t), 0, highPerformanceSIN(t), 0,
                            0, 1, 0, 0,
                            -highPerformanceSIN(t), 0, highPerformanceCOS(t), 0,
                            0, 0, 0, 1);
    return mak;
}

float4x4 rotation_matrix_xw(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(highPerformanceCOS(t), 0, 0, -highPerformanceSIN(t),
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            highPerformanceSIN(t), 0, 0, highPerformanceCOS(t));
    return mak;
}

float4x4 rotation_matrix_zw(float angle_deg) {
    float t = angle_deg * PI / 180;
    float4x4 mak = float4x4(1, 0, 0, 0,
                            0, 1, 0, 0,
                            0, 0, highPerformanceCOS(t), -highPerformanceSIN(t),
                            0, 0, highPerformanceSIN(t), highPerformanceCOS(t));
    return mak;
}

float4x4 rotation_matrix_xyzw(float xy, float yz, float zx, float wx, float wy, float wz) {
    float4x4 mak = rotation_matrix_yz(yz) * rotation_matrix_zx(zx) * rotation_matrix_xy(xy) * rotation_matrix_xw(wx) * rotation_matrix_yw(wy) * rotation_matrix_zw(wz);
    return mak;
}





float3 get_color_4d_box(float3 point, float camera_w, PrimitiveObject4d cube) {
    float4x4 rotation = cube.rotation_matrix;
    float4 transformation = cube.transformation4d;
    float4 semisize = cube.semisize;
    float4 p4d = float4(point, camera_w);
    float4 pp = (p4d + transformation) * rotation;
    float4 r = semisize;
    float4 p = pp;
    
    if(abs(p.x) - abs(r.x) >= 0 && abs(p.y) - abs(r.y) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.x) - abs(r.x) >= 0 && abs(p.z) - abs(r.z) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.y) - abs(r.y) >= 0 && abs(p.z) - abs(r.z) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.x) - abs(r.x) >= 0 && abs(p.w) - abs(r.w) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.y) - abs(r.y) >= 0 && abs(p.w) - abs(r.w) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.z) - abs(r.z) >= 0 && abs(p.w) - abs(r.w) >= 0) {
        return float3(1., 1., 1.);
    }
    
    if(abs(p.x) - abs(r.x) >= 0) {
        return float3(0., 0.5, 1);
    }
    
    if(abs(p.y) - abs(r.y) >= 0) {
        return float3(0., 0.5, 0.5);
    }
    
    if(abs(p.z) - abs(r.z) >= 0) {
        return float3(0., 0., 1.);
    }
    
    if(abs(p.w) - abs(r.w) >= 0) {
        return float3(0., 1., 0.5);
    }
    return float3(0.5, 1, 1);
}

float a_x(float3 p, PrimitiveObject4d obj) {
    return obj.signed_distance_function(float3(p.x + EPSILON, p.y, p.z), 0) - obj.signed_distance_function(float3(p.x - EPSILON, p.y, p.z), 0);
    
    
}

float a_y(float3 p, PrimitiveObject4d obj) {
    return obj.signed_distance_function(float3(p.x, p.y + EPSILON, p.z), 0) - obj.signed_distance_function(float3(p.x, p.y - EPSILON, p.z), 0);
    
    
}


float a_z(float3 p, PrimitiveObject4d obj) {
    return obj.signed_distance_function(float3(p.x, p.y, p.z + EPSILON), 0) - obj.signed_distance_function(float3(p.x, p.y, p.z - EPSILON), 0);
    
    
}


float a(float3 v) {
    return sqrt(v.x * v.x + v.y*v.y + v.z * v.z);
}

enum MergeType {join, intersect, difference};

struct Merger {
    PrimitiveObject4d obj_A;
    PrimitiveObject4d obj_B;
    float4 transformation4d;
    float4x4 rotation;
    MergeType merge_type;
    float power;
    Merger(PrimitiveObject4d _obj_A, PrimitiveObject4d _obj_B, float4 _transformation4d, float4x4 _rotation, MergeType _merge_type, float _power) {
        obj_A = _obj_A;
        obj_B = _obj_B;
        transformation4d = _transformation4d;
        rotation = _rotation;
        merge_type = _merge_type;
        power = _power;
    }
    
    Merger(){
        obj_A = PrimitiveObject4d();
        obj_B = PrimitiveObject4d();
        transformation4d = IDENTITY_TRANSFORMATION;
        rotation = IDENTITY_ROTATION_MATRIX;
        merge_type = join;
        power = 3;
    }
    
    float signed_distance_function(float3 point, float camera_w, float power = 0) {
        float4 point2 = float4(point, camera_w);
        float4 p = (point2 +  transformation4d) * rotation;
         
        if (merge_type == difference) {
            return max(obj_A.signed_distance_function(p.xyz, p.w), -(obj_B.signed_distance_function(p.xyz, p.w)));
        } else if ( merge_type == intersect ) {
            return max(obj_A.signed_distance_function(p.xyz, p.w), (obj_B.signed_distance_function(p.xyz, p.w)));
        } else {
            return min(obj_A.signed_distance_function(p.xyz, p.w), (obj_B.signed_distance_function(p.xyz, p.w)));
        }
        
    }
    
};



float a_x_merger(float4 p, Merger obj) {
    return obj.signed_distance_function(float3(p.x + EPSILON, p.y, p.z), p.w) - obj.signed_distance_function(float3(p.x - EPSILON, p.y, p.z), p.w);
}

float a_y_merger(float4 p, Merger obj) {
    return obj.signed_distance_function(float3(p.x, p.y + EPSILON, p.z), p.w) - obj.signed_distance_function(float3(p.x, p.y - EPSILON, p.z), p.w);
    
    
}


float a_z_merger(float4 p, Merger obj) {
    return obj.signed_distance_function(float3(p.x, p.y, p.z + EPSILON), p.w) - obj.signed_distance_function(float3(p.x, p.y, p.z - EPSILON), p.w);
}



kernel void compute (texture2d<float, access::write> output [[ texture(0) ]],
                     constant float &time [[ buffer(0) ]],
                     constant float3x4 &totalMak [[ buffer(1) ]],
                     constant int &primitive [[ buffer(2) ]],
                     constant float4 &object_color [[ buffer(3) ]],
                     constant int &resolution [[ buffer(4) ]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    if(gid.x % resolution == 0 && gid.y % resolution == 0) {
        int width = output.get_width();
        int height = output.get_height();
        int max_dim = max(width, height);
        // coordonatele normalizate
        float2 uv = (float2(gid) + float2(max((height - width) / 2, 0), max((width - height) / 2, 0))) / float2(max_dim, max_dim) ;
        uv = uv * 2.0 - 1.0;
        
        float3 rotation = totalMak.columns[0].xyz;
        float move_camera = totalMak.columns[0].w;
		
        float3 wrotation = totalMak.columns[1].xyz;
        float4 transformation4d = totalMak.columns[2];
        float3 lightorigin = float3(0.2, 0, -2.5);
        float3 col = float3(0.);
        if(object_color.x == 0) {
            col = float3(1.);
        }
        float4x4 rotmak = rotation_matrix_xyzw(rotation.z, rotation.x, rotation.y, wrotation.x, wrotation.y, wrotation.z);
        float4 dir4d;
        
        dir4d = float4(0.);
        
        float3 dir = dir4d.xyz;
        float camera_w = dir4d.w;
        float4 cube_dim = float4(0.5);
        if(primitive == SMOOTH_BOX || primitive == SMOOTH_CUBE) {
            cube_dim = float4(0.35);
        } else if (primitive == SPHERE) {
            cube_dim = float4(0.7);
        } else if (primitive == TORUS) {
            cube_dim = float4(0.7, 0.3, 0.1, 1);
        } else if (primitive == CUBE_THAT_TURNS_INTO_TORUS) {
            cube_dim = sdf_blend4(float4(0.5), float4(0.7, 0.3, 0.1, 1) , ( highPerformanceSIN(time) + 1) / 2.);
        }
        PrimitiveObject4d cube = PrimitiveObject4d(cube_dim, float4(0), IDENTITY_ROTATION_MATRIX, primitive);
        float4 other_cube_dim;
        
        if (primitive == CUBE_THAT_TURNS_INTO_SPHERE || primitive == CUBE_THAT_TURNS_INTO_TORUS) {
            cube.coefficient_for_changing_shape = ( highPerformanceSIN(time) + 1 ) / 2. ;
        }
        
        if (primitive == CUBE) {
            other_cube_dim = float4(0);
        } else if(primitive == BOX) {
            other_cube_dim = float4(0.4, 0.4, 0.4, 0.7);
        } else if(primitive == SMOOTH_BOX) {
            other_cube_dim = float4(0.2, 0.2, 0.2, 0.5);
        } else {
            other_cube_dim = float4(0);
        }
        PrimitiveObject4d other_cube = PrimitiveObject4d(other_cube_dim, float4(0, 0, 0, 0), IDENTITY_ROTATION_MATRIX, primitive);
        
        Merger merger;
        merger = Merger(cube, other_cube, transformation4d, rotmak, difference, 0);
        
        
        
        Ray ray = Ray(dir, normalize(float3(uv, 1.0)));
        float debth = 0;
        for (int i=0.; i<40.; i++) {
            
            float dist = merger.signed_distance_function(ray.origin, camera_w, ( (1 + highPerformanceSIN(time / 5)) * 10)*( (1 + highPerformanceSIN(time / 5)) * 1) );
            float total_dist = dist;
            debth += dist;
            if (total_dist < 0.005) {
                

                    float contactdx = a_x_merger(float4(ray.origin, camera_w), merger);
                    float contactdy = a_y_merger(float4(ray.origin, camera_w), merger);
                    float contactdz = a_z_merger(float4(ray.origin, camera_w), merger);
                    float3 gradient = normalize(float3(contactdx, contactdy, contactdz));
                    float3 color_diffuse = float3(0, 1, 1);
                    float3 color_spectru = 0.6 * float3(0, 1, 1);
                    float3 p = ray.origin;
                    float3 light_origin_normalized = normalize(lightorigin - p);
                    float3 dist_to_dir = normalize(dir - p);
                    float3 reflexion = normalize(reflect(-light_origin_normalized, gradient));
                    float3 lightIntensity = float3(0.7, 0.7, 0.7);
                    float dot_light_dir = dot(light_origin_normalized, gradient);
                    float dot_reflexion_pct = dot(reflexion, dist_to_dir);
                    float alpha = 2.0;
                    col = lightIntensity * (color_diffuse * dot_light_dir + color_spectru * pow(dot_reflexion_pct, alpha));
                    col = max(col, float3(0));
                    
                    col += float3(0, 1, 1) * 0.3;
                
                break;
                
            }
            
            if(debth > MAX_DEPTH) {
                break;
            }
            
            ray.origin += ray.direction * total_dist;
        }
        
        col = min(col, float3(1.));
        if(object_color.x != 0) {
            output.write(max(float4(col  , 1.), float4(0.109, 0.109, 0.117, 1.)), gid);
        } else {
            output.write(min(float4(col  , 1.), float4(1., 1., 1., 1.)), gid);
        }
        
    }
    
}

