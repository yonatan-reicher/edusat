#ifdef _MSC_VER
#include <ctime>

    double cpuTime() {
        return (double)clock() / CLOCKS_PER_SEC;
    }
#else

#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

    double cpuTime() {
        struct rusage ru;
        getrusage(RUSAGE_SELF, &ru);
        return (double)ru.ru_utime.tv_sec + (double)ru.ru_utime.tv_usec / 1000000;
    }
#endif
