#include "peripherals.hpp"

extern "C" int main(void) {
    // Initialize peripheral objects
    Leds leds;

    Button buttons[] = {Button(0), Button(1), Button(2), Button(3)};

    Switch switches[] = {Switch(0),Switch(1),Switch(2),Switch(3)};

    bool last_buttons[] = {false, false, false, false};

    // main program loop
    for (;;) {
        for (int i = 0; i < 4; i++) {
            bool active = buttons[i].active();
            if (active && !last_buttons[i]) {
                leds.toggle(i);
            }
            last_buttons[i] = active;
        }
    }
}
