#include <gtest/gtest.h>

TEST(Smoke, google_test_runs) {
  EXPECT_TRUE(true);
}

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

