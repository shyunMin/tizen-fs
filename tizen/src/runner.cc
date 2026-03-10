#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <dlog.h>

#include "runner.h"
#include "generated_plugin_registrant.h"

// 함수 포인터 타입 정의
typedef void *(*ecore_wl2_display_connect_t)(const char *name);
typedef void *(*ecore_wl2_display_disconnect_t)(void *display);
typedef int (*ecore_wl2_init_t)(void);
typedef void (*ecore_wl2_sync_t)(void);
typedef void *(*ecore_wl2_display_get_t)(void *display);
typedef void (*ecore_wl2_display_screen_size_get_t)(void *display, int *w, int *h);

class App : public FlutterApp
{
public:
  static inline const char *tag = "ConsoleMessage";

  bool OnCreate()
  {
    void *handle = dlopen("libecore_wl2.so.1", RTLD_LAZY);
    if (!handle)
    {
      fprintf(stderr, "Cannot open library: %s\n", dlerror());
    }

    ecore_wl2_display_connect_t ecore_wl2_display_connect = (ecore_wl2_display_connect_t)dlsym(handle, "ecore_wl2_display_connect");
    ecore_wl2_display_disconnect_t ecore_wl2_display_disconnect = (ecore_wl2_display_disconnect_t)dlsym(handle, "ecore_wl2_display_disconnect");
    ecore_wl2_init_t ecore_wl2_init = (ecore_wl2_init_t)dlsym(handle, "ecore_wl2_init");
    ecore_wl2_sync_t ecore_wl2_sync = (ecore_wl2_sync_t)dlsym(handle, "ecore_wl2_sync");
    ecore_wl2_display_get_t ecore_wl2_display_get = (ecore_wl2_display_get_t)dlsym(handle, "ecore_wl2_display_get");
    ecore_wl2_display_screen_size_get_t ecore_wl2_display_screen_size_get = (ecore_wl2_display_screen_size_get_t)dlsym(handle, "ecore_wl2_display_screen_size_get");

    char *error;
    if ((error = dlerror()) != NULL)
    {
      dlog_print(DLOG_ERROR, tag, "Cannot load symbol: %s\n", error);
      dlclose(handle);
      user_pixel_ratio_ = 2;
    }
    else
    {
      if (ecore_wl2_init() != 0)
      {
        dlog_print(DLOG_ERROR, tag, "Failed to initialize ecore_wl2\n");
        dlclose(handle);
      }

      void *display = ecore_wl2_display_connect(NULL);
      if (display == NULL)
      {
        dlog_print(DLOG_ERROR, tag, "Failed to connect to display\n");
        dlclose(handle);
        user_pixel_ratio_ = 2;
      }
      else
      {
        ecore_wl2_sync();

        int width, height;
        ecore_wl2_display_screen_size_get(display, &width, &height);
        dlog_print(DLOG_INFO, tag, "Screen size: %dx%d\n", width, height);

        ecore_wl2_display_disconnect(display);

        dlclose(handle);

        user_pixel_ratio_ = width / 960.0;
      }
    }

    if (FlutterApp::OnCreate())
    {
      RegisterPlugins(this);
    }
    return IsRunning();
  }
};

int main(int argc, char *argv[])
{
  App app;
  return app.Run(argc, argv);
}
