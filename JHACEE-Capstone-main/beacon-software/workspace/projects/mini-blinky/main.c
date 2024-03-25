/**
 * mini-blinky
 *
 * attempting to make the smallest blinky project possible to ensure that the
 * custom board we made actually works.
 *
 * testing shows that it does, but it would be nice to also allow it to blink
 * the single provided LED when it is working.
 *
 * the LED is linked to GPIO pin number 25
 *
 * as such, this program simply proves to be a test to ensure that the LED can
 * be lit.
 */
#include "boards.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"

int main() {
  // made with reference to:
  // https://www.youtube.com/watch?v=gvJ85OLFkOU
  const int LED_PIN = 4;
  nrf_gpio_cfg_output(LED_PIN);

  while(true) {
    nrf_gpio_pin_set(LED_PIN);
    nrf_delay_ms(500);
    nrf_gpio_pin_clear(LED_PIN);
    nrf_delay_ms(500);
  }
}
