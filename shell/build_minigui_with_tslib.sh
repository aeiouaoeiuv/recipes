#!/bin/sh

#
# Q:
#   incompatible types when assigning to type 'va_list' from type 'struct __va_list_tag *'
# A:
#   sudo apt-get install lib32z1 lib32stdc++6
#
# Ref: https://hceng.cn/2017/05/26/%E7%A7%BB%E6%A4%8DMiniGUI%E5%88%B0JZ2440/

set -e

###################### Environment ######################
if [ -z "$(which arm-oe-linux-gnueabi-gcc)" ];then
    echo -e "\033[38;5;9mFind no arm-oe-linux-gnueabi-gcc!!!"
    exit 1
fi
export SYSROOT_PATH=$HOME/sysroots/mdm9607
export INSTALL_PATH=${SYSROOT_PATH}
export TOPDIR=$PWD

###################### zlib-1.2.2 ######################
(
    if [ ! -d "zlib-1.2.2" ]; then
        if [ ! -e "zlib-1.2.2.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/zlib-1.2.2.tar.gz
        fi
        tar xf zlib-1.2.2.tar.gz
    fi
) &&

cd zlib-1.2.2/ &&

./configure --shared &&

echo 'diff --git a/Makefile b/Makefile
index 3f8f72a..c975f17 100644
--- a/Makefile
+++ b/Makefile
@@ -16,30 +16,31 @@
 # To install in $HOME instead of /usr/local, use:
 #    make install prefix=$HOME

-CC=gcc
+CROSS_COMPILE=arm-oe-linux-gnueabi-
+CC=${CROSS_COMPILE}gcc

-CFLAGS=-fPIC -O3 -DUSE_MMAP
+CFLAGS=-fPIC -O3 -DUSE_MMAP --sysroot=${SYSROOT_PATH}
 #CFLAGS=-O -DMAX_WBITS=14 -DMAX_MEM_LEVEL=7
 #CFLAGS=-g -DDEBUG
 #CFLAGS=-O3 -Wall -Wwrite-strings -Wpointer-arith -Wconversion \
 #           -Wstrict-prototypes -Wmissing-prototypes

 LDFLAGS=-L. libz.so.1.2.2
-LDSHARED=gcc -shared -Wl,-soname,libz.so.1
-CPP=gcc -E
+LDSHARED=${CC} -shared -Wl,-soname,libz.so.1 --sysroot=${SYSROOT_PATH}
+CPP=${CC} -E

 LIBS=libz.so.1.2.2
 SHAREDLIB=libz.so
 SHAREDLIBV=libz.so.1.2.2
 SHAREDLIBM=libz.so.1

-AR=ar rc
+AR=${CROSS_COMPILE}ar rc
 RANLIB=ranlib
 TAR=tar
 SHELL=/bin/sh
 EXE=

-prefix =/usr/local
+prefix =${INSTALL_PATH}
 exec_prefix =${prefix}
 libdir =${exec_prefix}/lib
 includedir =${prefix}/include' | patch -p1 &&

make && make install &&

cd ${TOPDIR} &&

###################### freetype-2.3.9-fm20100818 ######################
(
    if [ ! -d "freetype-2.3.9-fm20100818" ]; then
        if [ ! -e "freetype-2.3.9-fm20100818.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/freetype-2.3.9-fm20100818.tar.gz
        fi
        tar xf freetype-2.3.9-fm20100818.tar.gz
    fi
) &&

cd freetype-2.3.9-fm20100818/ &&

./configure \
--prefix=${INSTALL_PATH} \
CC="arm-oe-linux-gnueabi-gcc --sysroot=${SYSROOT_PATH}" \
CFLAGS="-I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
LDFLAGS="-L${SYSROOT_PATH}/lib -L${INSTALL_PATH}/lib" \
--host=arm-linux \
CXX="arm-oe-linux-gnueabi-g++ --sysroot=${SYSROOT_PATH} " \
CXXFLAGS="-I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" &&

make && make install &&

cd ${TOPDIR} &&

###################### jpeg-7 ######################
(
    if [ ! -d "jpeg-7" ]; then
        if [ ! -e "jpegsrc.v7.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/jpegsrc.v7.tar.gz
        fi
        tar xf jpegsrc.v7.tar.gz
    fi
) &&

cd jpeg-7/ &&

./configure \
--host=arm-oe-linux-gnueabi \
--prefix=${INSTALL_PATH} \
CC="arm-oe-linux-gnueabi-gcc --sysroot=${SYSROOT_PATH}" \
CFLAGS="--sysroot=${SYSROOT_PATH}" \
--enable-shared &&

make && make install &&

cd ${TOPDIR} &&

###################### libpng ######################
(
    if [ ! -d "libpng-1.2.37" ]; then
        if [ ! -e "libpng-1.2.37.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/libpng-1.2.37.tar.gz
        fi
        tar xf libpng-1.2.37.tar.gz
    fi
) &&

cd libpng-1.2.37/ &&

./configure \
--host=arm-oe-linux-gnueabi \
--prefix=${INSTALL_PATH} \
CC="arm-oe-linux-gnueabi-gcc --sysroot=${SYSROOT_PATH}" \
CFLAGS="--sysroot=${SYSROOT_PATH}" &&

make && make install &&

cd ${TOPDIR} &&

###################### tslib ######################
(
echo -e 'diff -urN tslib-1.20/tests/fbutils-linux.c tslib-1.20_mod/tests/fbutils-linux.c
--- tslib-1.20/tests/fbutils-linux.c	2019-05-18 16:23:11.000000000 -0400
+++ tslib-1.20_mod/tests/fbutils-linux.c	2019-06-09 22:59:43.376030761 -0400
@@ -56,6 +56,25 @@
 
 #define VTNAME_LEN 128
 
+void GAL_Update_FB(int console_fd)
+{
+    struct fb_var_screeninfo vinfo;
+    memset(&vinfo, 0, sizeof(struct fb_var_screeninfo));
+    /* Set the video mode and get the final screen format */
+    if ( ioctl(console_fd, FBIOGET_VSCREENINFO, &vinfo) < 0 )
+    {
+        fprintf (stderr, "Couldn\x27t get console screen info");
+        return ;
+    }
+    vinfo.xoffset = 0;
+    vinfo.yoffset = 0;
+    if (ioctl(console_fd, FBIOPAN_DISPLAY, &vinfo) < 0)
+    {
+        fprintf(stderr, "Serious error, offset framebuffer failed.\\n");
+        return ;
+    }
+}
+
 int open_framebuffer(void)
 {
 	struct vt_stat vts;
@@ -173,6 +192,13 @@
 	for (y = 0; y < var.yres_virtual; y++, addr += fix.line_length)
 		line_addr[y] = fbuffer + addr;
 
+    GAL_Update_FB(fb_fd);
+    //if (ioctl(fb_fd, FBIOPAN_DISPLAY, &fix) < 0)
+    //{
+    //    perror("Serious error, offset framebuffer failed");
+    //    return -1;
+    //}
+
 	return 0;
 }
 
@@ -222,6 +248,7 @@
 		line(x + 4, y - 4, x + 7, y - 7, colidx + 1);
 		line(x + 4, y + 4, x + 7, y + 7, colidx + 1);
 	}
+    GAL_Update_FB(fb_fd);
 }
 
 static void put_char(int32_t x, int32_t y, int32_t c, int32_t colidx)
@@ -234,6 +261,7 @@
 			if (bits & 0x80)
 				pixel(x + j, y + i, colidx);
 	}
+    GAL_Update_FB(fb_fd);
 }
 
 void put_string(int32_t x, int32_t y, char *s, uint32_t colidx)
@@ -476,4 +504,5 @@
 			loc.p8 += bytes_per_pixel;
 		}
 	}
+    GAL_Update_FB(fb_fd);
 }
' > ${TOPDIR}/tslib-1.20.patch
) &&

(
    if [ ! -d "tslib-1.20" ]; then
        if [ ! -e "tslib-1.20.tar.gz" ]; then
            wget -c https://github.com/libts/tslib/releases/download/1.20/tslib-1.20.tar.gz
        fi
        tar xf tslib-1.20.tar.gz
    fi
) &&

cd tslib-1.20/ &&

(
    if ! patch -R -N -p1 --dry-run < ${TOPDIR}/tslib-1.20.patch; then
        # unpatched, apply patch
        patch -p1 < ${TOPDIR}/tslib-1.20.patch
    fi
) &&

./configure \
--prefix=$INSTALL_PATH \
--host=arm-oe-linux-gnueabi \
CFLAGS="--sysroot=$SYSROOT_PATH" &&

make && make install &&

cd ${TOPDIR} &&

###################### libminigui-3.0.12-linux ######################
(
echo -e 'diff --git a/src/ial/dummy.c b/src/ial/dummy.c
index c276b6b..fa1fd51 100644
--- a/src/ial/dummy.c
+++ b/src/ial/dummy.c
@@ -1,111 +1,224 @@
-/*
-** $Id: dummy.c 13694 2010-12-22 07:14:58Z wanzheng $
-**
-** dummy.c: The dummy IAL engine.
-** 
-** Copyright (C) 2003 ~ 2007 Feynman Software.
-** Copyright (C) 2001 ~ 2002 Wei Yongming.
-**
-** Created by Wei Yongming, 2001/09/13
-*/
-
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <unistd.h>
+#include <fcntl.h>
+
 
 #include "common.h"
+#include "tslib.h"
+
 
 #ifdef _MGIAL_DUMMY
 
-#include "misc.h"
+
+#include <sys/ioctl.h>
+#include <sys/poll.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <linux/kd.h>
+
+
 #include "ial.h"
 #include "dummy.h"
 
-static int mouse_x, mouse_y, mouse_button;
 
-typedef struct tagPOS
-{
-	short x;
-	short y;
-	short b;
-} POS;
+#ifndef _DEBUG
+#define _DEBUG                    // for debugging
+#endif
+
+
+/* for storing data reading from /dev/touchScreen/0raw */
+typedef struct {
+       unsigned short pressure;
+       unsigned short x;
+       unsigned short y;
+       unsigned short pad;
+} TS_EVENT;
+
+
+static unsigned char state [NR_KEYS];
+static int mousex = 0;
+static int mousey = 0;
+static TS_EVENT ts_event;
+static struct tsdev *ts;
 
-/************************  Low Level Input Operations **********************/
+
+/************************ Low Level Input Operations **********************/
 /*
- * Mouse operations -- Event
- */
+* Mouse operations -- Event
+*/
 static int mouse_update(void)
 {
-	return 1;
+        return 1;
 }
 
-static void mouse_getxy (int* x, int* y)
-{
-	*x = mouse_x;
-    *y = mouse_y;
-}
 
-static int mouse_getbutton(void)
+static void mouse_getxy(int *x, int* y)
 {
-	return mouse_button;
-}
+        if (mousex < 0) mousex = 0;
+        if (mousey < 0) mousey = 0;
+        if (mousex > 639) mousex = 639;
+        if (mousey > 479) mousey = 479;
 
-static int keyboard_update(void)
-{
-	return 0;
+
+#ifdef _DEBUG
+       // printf ("mousex = %d, mousey = %d\\n", mousex, mousey);
+#endif
+
+
+       *x = mousex;
+       *y = mousey;
 }
 
-static const char * keyboard_get_state (void)
+
+static int mouse_getbutton(void)
 {
-	return NULL;
+        return ts_event.pressure;
 }
 
+
+#ifdef _LITE_VERSION
 static int wait_event (int which, int maxfd, fd_set *in, fd_set *out, fd_set *except,
-                struct timeval *timeout)
-{
-#ifdef _MGRM_THREADS
-    __mg_os_time_delay (300);
+                        struct timeval *timeout)
 #else
-	fd_set rfds;
-	int	e;
+static int wait_event (int which, fd_set *in, fd_set *out, fd_set *except,
+                        struct timeval *timeout)
+#endif
+{
+        struct ts_sample sample;
+        int ret = 0;
+        int fd;
+        fd_set rfds;
+        int e;
+
 
-    if (!in) {
-        in = &rfds;
-        mg_fd_zero (in);
-    }
+       if (!in) {
+              in = &rfds;
+              FD_ZERO (in);
+       }
 
-	e = mg_select (maxfd + 1, in, out, except, timeout) ;
 
-    if (e < 0) {
-		return -1;
-	}
+fd = ts_fd(ts);
+
+
+       if ((which & IAL_MOUSEEVENT) && fd >= 0) {
+              FD_SET (fd, in);
+#ifdef _LITE_VERSION
+              if (fd > maxfd) maxfd = fd;
+#endif
+        }
+#ifdef _LITE_VERSION
+       e = select (maxfd + 1, in, out, except, timeout) ;
+#else
+      e = select (FD_SETSIZE, in, out, except, timeout) ;
 #endif
 
-	return 0;
-}
 
-BOOL InitDummyInput (INPUT* input, const char* mdev, const char* mtype)
+       if (e > 0) {
+
+
+            // input events is coming
+             if (fd > 0 && FD_ISSET (fd, in)) {
+                   FD_CLR (fd, in);
+                   ts_event.x=0;
+                  ts_event.y=0;
+
+
+                  ret = ts_read(ts, &sample, 1);
+                  if (ret < 0) {
+                        perror("ts_read()");
+                        exit(-1);
+                  }
+
+
+                  ts_event.x = sample.x;
+                  ts_event.y = sample.y;
+                  ts_event.pressure = (sample.pressure > 0 ? 4:0);
+
+
+               //   if (ts_event.pressure > 0 &&
+                     if((ts_event.x >= 0 && ts_event.x <= 639) &&
+                        (ts_event.y >= 0 && ts_event.y <= 479)) {
+                        mousex = ts_event.x;
+                         mousey = ts_event.y;
+                   // printf("ts_event.x is %d, ts_event.y is %d------------------------------------->\\n",ts_event.x ,ts_event.y);
+                   }
+
+
+//#ifdef _DEBUG
+              //    if (ts_event.pressure > 0) {
+        //  printf ("mouse down: ts_event.x = %d, ts_event.y = %d,ts_event.pressure = %d\\n",ts_event.x,ts_event.y,ts_event.pressure);
+               //   }
+//#endif
+                   ret |= IAL_MOUSEEVENT;
+
+
+                  return (ret);
+             }
+
+
+      }
+       else if (e < 0) {
+             return -1;
+      }
+
+
+       return (ret);
+}BOOL InitDummyInput(INPUT* input, const char* mdev, const char* mtype)
 {
-    input->update_mouse = mouse_update;
-    input->get_mouse_xy = mouse_getxy;
-    input->set_mouse_xy = NULL;
-    input->get_mouse_button = mouse_getbutton;
-    input->set_mouse_range = NULL;
-
-    input->update_keyboard = keyboard_update;
-    input->get_keyboard_state = keyboard_get_state;
-    input->set_leds = NULL;
-
-    input->wait_event = wait_event;
-	mouse_x = 0;
-	mouse_y = 0;
-	mouse_button= 0;
-    return TRUE;
+      char *ts_device = NULL;
+
+
+       if ((ts_device = getenv("TSLIB_TSDEVICE")) != NULL) {
+
+
+            // open touch screen event device in blocking mode
+            ts = ts_open(ts_device, 0);
+      } else {
+#ifdef USE_INPUT_API
+             ts = ts_open("/dev/input/0raw", 0);
+#else
+             ts = ts_open("/dev/touchscreen/ucb1x00", 0);
+#endif
+      }
+#ifdef _DEBUG
+        printf ("TSLIB_TSDEVICE is open!!!!!!!!!!!\\n");
+#endif
+       if (!ts) {
+           perror("ts_open()");
+             exit(-1);
+       }
+
+
+      if (ts_config(ts)) {
+            perror("ts_config()");
+            exit(-1);
+       }
+
+
+      input->update_mouse = mouse_update;
+      input->get_mouse_xy = mouse_getxy;
+      input->set_mouse_xy = NULL;
+      input->get_mouse_button = mouse_getbutton;
+      input->set_mouse_range = NULL;
+
+
+      input->wait_event = wait_event;
+      mousex = 0;
+      mousey = 0;
+      ts_event.x = ts_event.y = ts_event.pressure = 0;
+
+
+       return TRUE;
 }
 
-void TermDummyInput (void)
+
+void TermDummyInput(void)
 {
+      if (ts)
+            ts_close(ts);
 }
 
-#endif /* _MGIAL_DUMMY */
 
+#endif /* _MGIAL_DUMMY */
diff --git a/src/newgal/fbcon/fbvideo.c b/src/newgal/fbcon/fbvideo.c
index 0706778..8e172ee 100644
--- a/src/newgal/fbcon/fbvideo.c
+++ b/src/newgal/fbcon/fbvideo.c
@@ -492,6 +492,25 @@ static void print_finfo(struct fb_fix_screeninfo *finfo)
 }
 #endif
 
+void GAL_Update_FB(_THIS)
+{
+    struct fb_var_screeninfo vinfo;
+    memset(&vinfo, 0, sizeof(struct fb_var_screeninfo));
+    /* Set the video mode and get the final screen format */
+    if ( ioctl(console_fd, FBIOGET_VSCREENINFO, &vinfo) < 0 )
+    {
+        fprintf (stderr, "Couldn\x27t get console screen info");
+        return ;
+    }
+    vinfo.xoffset = 0;
+    vinfo.yoffset = 0;
+    if (ioctl(console_fd, FBIOPAN_DISPLAY, &vinfo) < 0)
+    {
+        fprintf(stderr, "Serious error, offset framebuffer failed.\\n");
+        return ;
+    }
+}
+
 static GAL_Surface *FB_SetVideoMode(_THIS, GAL_Surface *current,
                 int width, int height, int bpp, Uint32 flags)
 {
diff --git a/src/newgal/fbcon/fbvideo.h b/src/newgal/fbcon/fbvideo.h
index 6878622..f707b74 100644
--- a/src/newgal/fbcon/fbvideo.h
+++ b/src/newgal/fbcon/fbvideo.h
@@ -150,5 +150,7 @@ static __inline__ void FB_dst_to_xy(_THIS, GAL_Surface *dst, int *x, int *y)
     }
 }
 
+extern void GAL_Update_FB(_THIS);
+
 #endif /* _GAL_fbvideo_h */
 
diff --git a/src/newgal/video.c b/src/newgal/video.c
index e2ceab1..3068004 100644
--- a/src/newgal/video.c
+++ b/src/newgal/video.c
@@ -670,6 +670,15 @@ void GAL_UpdateRect(GAL_Surface *screen, Sint32 x, Sint32 y, Uint32 w, Uint32 h)
     }
 }
 
+void GAL_Update()
+{
+    GAL_Surface *screen = GAL_GetVideoSurface();
+    GAL_VideoDevice *video = (GAL_VideoDevice *) screen->video;
+    if (!video)
+        return;
+    GAL_Update_FB(video);
+}
+
 void GAL_UpdateRects (GAL_Surface *screen, int numrects, GAL_Rect *rects)
 {
     GAL_VideoDevice *this =(GAL_VideoDevice *) screen->video;
@@ -683,6 +692,7 @@ void GAL_UpdateRects (GAL_Surface *screen, int numrects, GAL_Rect *rects)
             this->UpdateSurfaceRects(this, screen, numrects, rects);
         }
     }
+    GAL_Update_FB(this);
 }
 
 static void SetPalette_logical(GAL_Surface *screen, GAL_Color *colors,
' > ${TOPDIR}/libminigui-3.0.12-linux.patch
) &&

(
    if [ ! -d "libminigui-3.0.12-linux" ]; then
        if [ ! -e "libminigui-3.0.12-linux.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/libminigui-3.0.12-linux.tar.gz
        fi
        tar xf libminigui-3.0.12-linux.tar.gz
    fi
) &&

cd libminigui-3.0.12-linux/ &&

(
    if ! patch -R -N -p1 --dry-run < ${TOPDIR}/libminigui-3.0.12-linux.patch; then
        # unpatched, apply patch
        patch -p1 < ${TOPDIR}/libminigui-3.0.12-linux.patch
    fi
) &&

./configure \
--host=arm-oe-linux-gnueabi \
--prefix=${INSTALL_PATH} \
CC="arm-oe-linux-gnueabi-gcc --sysroot=${SYSROOT_PATH}" \
CFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include -I${INSTALL_PATH}/include/freetype2" \
LDFLAGS="-L${SYSROOT_PATH}/lib -L${INSTALL_PATH}/lib -lpng -ljpeg -lts" \
--with-targetname=fbcon \
--enable-standalone \
--with-ttfsupport=ft2 \
--with-ft2-includes=${INSTALL_PATH}/include/freetype2 &&

sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/pcxvfb/Makefile.in &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/pcxvfb/Makefile.am &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/qvfb/Makefile.in &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/qvfb/Makefile.am &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/rtos_xvfb/Makefile.in &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/rtos_xvfb/Makefile.am &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/gdl/Makefile.in &&
sed -i "s| -I\/usr\/include\/| -I${INSTALL_PATH}/include\/|g" ./src/newgal/gdl/Makefile.am &&

#--disable-jpgsupport
#--enable-pngsupport
#--disable-screensaver

make && make install &&

cd ${TOPDIR} &&

###################### libmgplus ######################

(
    if [ ! -d "libmgplus-1.2.4" ]; then
        if [ ! -e "libmgplus-1.2.4.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/libmgplus-1.2.4.tar.gz
        fi
        tar xf libmgplus-1.2.4.tar.gz
    fi
) &&

cd libmgplus-1.2.4 &&

./configure \
--host=arm-oe-linux-gnueabi \
--prefix=${INSTALL_PATH} \
CC="arm-oe-linux-gnueabi-gcc --sysroot=${SYSROOT_PATH}" \
CFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
CPPFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
LDFLAGS="--sysroot=${SYSROOT_PATH} -L${SYSROOT_PATH}/lib -L${INSTALL_PATH}/lib" \
MINIGUI_CFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
MINIGUI_LIBS="-L${SYSROOT_PATH}/lib -L${INSTALL_PATH}/lib -lminigui_sa -lm" &&

make && make install &&

cd ${TOPDIR} &&

###################### mg-samples-3.0.12 ######################

(
    if [ ! -d "mg-samples-3.0.12" ]; then
        if [ ! -e "mg-samples-3.0.12.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/mg-samples-3.0.12.tar.gz
        fi
        tar xf mg-samples-3.0.12.tar.gz
    fi
) &&

cd mg-samples-3.0.12/ &&

./configure \
--host=arm-oe-linux-gnueabi \
--prefix=${INSTALL_PATH} \
CFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
LDFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/lib -L${INSTALL_PATH}/lib" \
MINIGUI_CFLAGS="--sysroot=${SYSROOT_PATH} -I${SYSROOT_PATH}/include -I${INSTALL_PATH}/include" \
MINIGUI_LIBS="-L${INSTALL_PATH}/lib -lminigui_sa -lm" &&

make &&

cd ${TOPDIR} &&

###################### minigui-res-be-3.0.12 ######################

(
    if [ ! -d "minigui-res-be-3.0.12" ]; then
        if [ ! -e "minigui-res-be-3.0.12.tar.gz" ]; then
            wget -c http://www.minigui.com/downloads/minigui-res-be-3.0.12.tar.gz
        fi
        tar xf minigui-res-be-3.0.12.tar.gz
    fi
) &&

cd minigui-res-be-3.0.12/ &&

#if [ ! -d "tmp" ]; then
#    mkdir tmp/
#fi

./configure --prefix=$PWD/tmp/ &&

make && make install &&

cd ${TOPDIR} &&

###################### Finish ######################
echo -e "\033[38;5;48mbuilding finished!"

