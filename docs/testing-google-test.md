# Native Google Test with PlatformIO

This bundle includes `.devenvironment/platformio-native-test.ini`.

Enable it from `platformio.ini`:

```ini
[platformio]
extra_configs =
  .devenvironment/platformio-check.ini
  .devenvironment/platformio-native-test.ini
```

Run native tests:

```bash
make test-native
```

This only runs after the extra config is listed in `platformio.ini`; otherwise PlatformIO will not know about the `native` environment.

Run native coverage:

```bash
make coverage
```

Coverage output is written to `coverage/index.html`.

## Recommended layout

Keep hardware-independent logic in small libraries that can compile on your PC:

```text
lib/
  core_logic/
    src/
    include/
test/
  test_core_logic/
    test_core_logic.cpp
```

Keep direct hardware calls behind thin adapters, then test the logic without needing the board connected.

## Minimal Google Test

```cpp
#include <gtest/gtest.h>

int add(int a, int b) {
  return a + b;
}

TEST(Math, adds_two_numbers) {
  EXPECT_EQ(add(2, 3), 5);
}

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

## Hardware-specific code

The native test environment defines `PIO_UNIT_TESTING`. Use it sparingly to exclude board-only code:

```cpp
#ifndef PIO_UNIT_TESTING
#include <Arduino.h>
#endif
```

If a module needs many `#ifdef` blocks, split the hardware adapter from the pure logic instead.
