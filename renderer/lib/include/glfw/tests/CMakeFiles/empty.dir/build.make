# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/dhc/EvoAlgo/assignment3c/renderer

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/dhc/EvoAlgo/assignment3c/renderer

# Include any dependencies generated for this target.
include lib/include/glfw/tests/CMakeFiles/empty.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include lib/include/glfw/tests/CMakeFiles/empty.dir/compiler_depend.make

# Include the progress variables for this target.
include lib/include/glfw/tests/CMakeFiles/empty.dir/progress.make

# Include the compile flags for this target's objects.
include lib/include/glfw/tests/CMakeFiles/empty.dir/flags.make

lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/flags.make
lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o: lib/include/glfw/tests/empty.c
lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/dhc/EvoAlgo/assignment3c/renderer/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o -MF CMakeFiles/empty.dir/empty.c.o.d -o CMakeFiles/empty.dir/empty.c.o -c /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests/empty.c

lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/empty.dir/empty.c.i"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests/empty.c > CMakeFiles/empty.dir/empty.c.i

lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/empty.dir/empty.c.s"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests/empty.c -o CMakeFiles/empty.dir/empty.c.s

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/flags.make
lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o: lib/include/glfw/deps/tinycthread.c
lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/dhc/EvoAlgo/assignment3c/renderer/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o -MF CMakeFiles/empty.dir/__/deps/tinycthread.c.o.d -o CMakeFiles/empty.dir/__/deps/tinycthread.c.o -c /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/tinycthread.c

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/empty.dir/__/deps/tinycthread.c.i"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/tinycthread.c > CMakeFiles/empty.dir/__/deps/tinycthread.c.i

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/empty.dir/__/deps/tinycthread.c.s"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/tinycthread.c -o CMakeFiles/empty.dir/__/deps/tinycthread.c.s

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/flags.make
lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o: lib/include/glfw/deps/glad_gl.c
lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o: lib/include/glfw/tests/CMakeFiles/empty.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/dhc/EvoAlgo/assignment3c/renderer/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building C object lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o -MF CMakeFiles/empty.dir/__/deps/glad_gl.c.o.d -o CMakeFiles/empty.dir/__/deps/glad_gl.c.o -c /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/glad_gl.c

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/empty.dir/__/deps/glad_gl.c.i"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/glad_gl.c > CMakeFiles/empty.dir/__/deps/glad_gl.c.i

lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/empty.dir/__/deps/glad_gl.c.s"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/deps/glad_gl.c -o CMakeFiles/empty.dir/__/deps/glad_gl.c.s

# Object files for target empty
empty_OBJECTS = \
"CMakeFiles/empty.dir/empty.c.o" \
"CMakeFiles/empty.dir/__/deps/tinycthread.c.o" \
"CMakeFiles/empty.dir/__/deps/glad_gl.c.o"

# External object files for target empty
empty_EXTERNAL_OBJECTS =

lib/include/glfw/tests/empty: lib/include/glfw/tests/CMakeFiles/empty.dir/empty.c.o
lib/include/glfw/tests/empty: lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/tinycthread.c.o
lib/include/glfw/tests/empty: lib/include/glfw/tests/CMakeFiles/empty.dir/__/deps/glad_gl.c.o
lib/include/glfw/tests/empty: lib/include/glfw/tests/CMakeFiles/empty.dir/build.make
lib/include/glfw/tests/empty: lib/include/glfw/src/libglfw3.a
lib/include/glfw/tests/empty: /usr/lib/x86_64-linux-gnu/libm.so
lib/include/glfw/tests/empty: /usr/lib/x86_64-linux-gnu/librt.so
lib/include/glfw/tests/empty: /usr/lib/x86_64-linux-gnu/libX11.so
lib/include/glfw/tests/empty: lib/include/glfw/tests/CMakeFiles/empty.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/dhc/EvoAlgo/assignment3c/renderer/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Linking C executable empty"
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/empty.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/include/glfw/tests/CMakeFiles/empty.dir/build: lib/include/glfw/tests/empty
.PHONY : lib/include/glfw/tests/CMakeFiles/empty.dir/build

lib/include/glfw/tests/CMakeFiles/empty.dir/clean:
	cd /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests && $(CMAKE_COMMAND) -P CMakeFiles/empty.dir/cmake_clean.cmake
.PHONY : lib/include/glfw/tests/CMakeFiles/empty.dir/clean

lib/include/glfw/tests/CMakeFiles/empty.dir/depend:
	cd /home/dhc/EvoAlgo/assignment3c/renderer && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/dhc/EvoAlgo/assignment3c/renderer /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests /home/dhc/EvoAlgo/assignment3c/renderer /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests /home/dhc/EvoAlgo/assignment3c/renderer/lib/include/glfw/tests/CMakeFiles/empty.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/include/glfw/tests/CMakeFiles/empty.dir/depend
