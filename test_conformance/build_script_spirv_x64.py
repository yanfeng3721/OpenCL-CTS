#!/usr/bin/env python3
# Script parameters:
# 1 - input file
# 2 - output file
# 3 - architecture: 32 or 64
# 4 - one of the strings: binary, source, spir_v
# 5 - OpenCL version: 12, 20
# 6 - build options

import os
import sys
import re

if len(sys.argv) < 5:
    print(
        'Usage: "build_script_spirv.py <input> <output> <arch> <output_type> <opencl_version> [build_options]"'
    )
    exit(1)

output_type = sys.argv[1]
print("output_type ", output_type)
source = sys.argv[2]
print("source", source)
output = sys.argv[3]
print("output", output)
device_info = sys.argv[4]
print("device_info", device_info)
#trash = sys.argv[5]
#arch = sys.argv[5]
#print ("arch", arch)
#ocl_version = sys.argv[5]
#print ("ocl_version", ocl_version)
build_options = ''

tools_arch_postfix = ''

input_file = source.replace("--source=", "")
output_file = output.replace("--output=", "")
#options_file_name = input_file.replace(".cl", ".options")
#optFile = open (os.path.join(root, options_file_name), 'r')
#build_options = optFile.readline().strip()
#print(build_options)

opencl_features = {
    '__opencl_c_3d_image_writes', '__opencl_c_atomic_order_acq_rel',
    '__opencl_c_atomic_order_seq_cst', '__opencl_c_atomic_scope_all_devices',
    '__opencl_c_atomic_scope_device', '__opencl_c_device_enqueue',
    '__opencl_c_fp64', '__opencl_c_generic_address_space', '__opencl_c_images',
    '__opencl_c_int64', '__opencl_c_pipes',
    '__opencl_c_program_scope_global_variables',
    '__opencl_c_read_write_images', '__opencl_c_subgroups',
    '__opencl_c_work_group_collective_functions'
}

build_options += '-cl-ext=+' + ',+'.join(opencl_features) + ' '
build_options += " -D__IMAGE_SUPPORT__=1 "

print("len: ", len((sys.argv)))
if len(sys.argv) > 7:
    for i in range(6, len(sys.argv) - 1):
        build_options += sys.argv[i] + ' '
print("build opt", build_options)

if output_type == '--mode=spir-v':
    output_type = 'spir_v'

#if arch == '32':
#	arch_string = ''
#	spir_arch = '__i386__'
#	tools_arch_postfix = '32'
#else:
arch_string = '64'
spir_arch = '__x86_64__'

#if ocl_version == '-cl-std=CL2.0':
oclc_version = '300'
spir_version = '3.0'
spir_ver = '30'
#else:
#	oclc_version = '120'
#	spir_version = '1.2'
#	spir_ver = '12'

command = '"' + os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    ('clangSpirV' + tools_arch_postfix)
) + '" -cc1 -include opencl-c.h -cl-std=CL' + spir_version + ' -fno-validate-pch -x cl -O2 -emit-llvm-bc -triple spir' + arch_string + ' ' + build_options + ' ' + input_file + ' -o ' + output_file + '.bc'
print(command)
os.system(command)

command = '"' + os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    ('llvm-spirv' + tools_arch_postfix)
) + '" ' + output_file + '.bc -o ' + output_file
print(command)
os.system(command)
