#include "stm32l476xx.h"
#include "7-seg.h"

#define TIME_SEC 12.7

int intlen (int n);
void timer_init (TIM_TypeDef *timer);
void timer_start (TIM_TypeDef *timer);

int main (void)
{
	int		n = 0;
	uint32_t	time = 0;
	TIM_TypeDef	*timer = TIM2;

	max7219_init ();
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	timer_init (timer);
	timer_start (timer);

	if (TIME_SEC < 0.01 || TIME_SEC > 10000) {
		display (n, intlen (n));
		return 0;
	}

	while (1) {
		if (n < 100 * TIME_SEC && time != timer->CNT) {
			++n;
			time = timer->CNT;
		}
		display (n, intlen (n));
	}

	return 0;
}

void timer_init (TIM_TypeDef *timer)
{
	timer->PSC = (uint32_t) 39999;
	timer->ARR = (uint32_t) 99;
	timer->EGR = TIM_EGR_UG;
}

void timer_start (TIM_TypeDef *timer)
{
	timer->CR1 |= TIM_CR1_CEN;
}

int intlen (int n)
{
	int len = 1;
	while (n > 9) {
		n /= 10;
		++len;
	}
	return len < 3 ? 3 : len;
}
