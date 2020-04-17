#include "GoogleTestApp.h"

#include "gtest/gtest.h"

class FirstTest : public ::testing::Test
{
};

TEST_F(FirstTest, ShouldTestTrue)
{
    ASSERT_TRUE(true);
}
TEST_F(FirstTest, ShouldTestFalse)
{
    ASSERT_FALSE(true);
}
