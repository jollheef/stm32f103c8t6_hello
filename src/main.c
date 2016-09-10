#include <stm32f10x.h>
#include <stm32f10x_gpio.h>
#include <stm32f10x_rcc.h>

struct pin {
	GPIO_TypeDef* gpio;
	GPIO_InitTypeDef init;
};

void delay_us(uint32_t us)
{
	volatile uint32_t n = 8 * us;

	while(--n > 0);
}

void delay_ms(uint32_t ms)
{
	volatile uint32_t n = 1000;

	while(--n > 0)
		delay_us(ms);
}

int main(void)
{
	RCC->APB2ENR |= RCC_APB2Periph_GPIOA;

        struct pin led = {GPIOA, {GPIO_Pin_0, GPIO_Mode_Out_PP, GPIO_Speed_2MHz}};
        GPIO_Init(led.gpio, &led.init);

	while(1) {
                GPIO_ResetBits(led.gpio, led.init.GPIO_Pin);

		delay_ms(100);

                GPIO_SetBits(led.gpio, led.init.GPIO_Pin);

		delay_ms(100);
	}

	return 0;
}
