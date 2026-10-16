#include "peripherals.hpp"

extern "C" int main(void) {
    // Initialize peripheral objects
    Leds leds;

    Button buttons[] = {Button(0), Button(1), Button(2), Button(3)};

    Switch switches[] = {Switch(0),Switch(1),Switch(2),Switch(3)};

    // main program loop
    for (;;) {
        for (int i = 0; i < 4; i++) {
            if (buttons[i].active() != switches[i].active()) {
                leds.activate(i);
            }
            else {
                leds.deactivate(i);
            }
        }
    }
}
