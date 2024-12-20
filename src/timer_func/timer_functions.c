#include <stddef.h>  // for NULL
#include "timer.h"

double get_current_time() {
    double now;
    GET_TIME(now);
    return now;
}